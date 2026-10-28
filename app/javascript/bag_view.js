/**
 * Bag View - draws the collection bag as a see-through SVG and fills it with sawdust.
 * Ported from dc-level-app (frontend/js/bag.js), with the fabric recolored for a light background.
 */

// Oblique view of the bag: front face, plus the right side and top seen from above-right
const BAG_GEOMETRY = {
    x0: 140, x1: 520,         // front face left/right
    yTop: 230, yBottom: 700,  // front face top/bottom
    dx: 120, dy: -70,         // offset from the front face to the back face
    bulge: 12,                // how far the filled sides bow out
    particles: 2400,
    animationMs: 1500
};

const SAWDUST_COLORS = ['#f2ddb6', '#e8c99a', '#d9b382', '#c89b62', '#b5884f', '#a0743f', '#8a6335'];

const BagView = {
    g: null,
    els: {},
    level: 0,
    animationFrame: null,

    init(svg, capacityYd3) {
        this.g = this.geometry();
        svg.innerHTML = this.buildMarkup(capacityYd3);
        ['sawdust', 'frontDust', 'sideDust', 'sideShade', 'surface', 'heap', 'clipBody', 'clipHeap']
            .forEach(id => { this.els[id] = document.getElementById(`bag-${id}`); });
        this.draw(0);
    },

    // Animate the sawdust to a new level (0..1); stale readings are drawn greyed out
    setLevel(fraction, stale) {
        this.els.sawdust.classList.toggle('stale', stale);

        const from = this.level;
        const to = Math.min(Math.max(fraction, 0), 1);
        const start = performance.now();
        cancelAnimationFrame(this.animationFrame);

        const step = (now) => {
            const t = Math.min((now - start) / BAG_GEOMETRY.animationMs, 1);
            const eased = 1 - Math.pow(1 - t, 3);
            this.draw(from + (to - from) * eased);
            if (t < 1) {
                this.animationFrame = requestAnimationFrame(step);
            }
        };
        this.animationFrame = requestAnimationFrame(step);
    },

    draw(fraction) {
        this.level = fraction;
        const g = this.g;
        const pad = 40;
        const yFront = g.yBottom - fraction * (g.yBottom - g.yTop);  // sawdust surface at the front face
        const yBack = yFront + g.dy;                                  // ...and at the back face

        this.els.sawdust.style.display = fraction > 0.002 ? '' : 'none';

        this.els.frontDust.setAttribute('y', yFront);
        this.els.frontDust.setAttribute('height', g.yBottom + pad - yFront);

        const side = `${g.x1},${yFront} ${g.bx1},${yBack} ${g.bx1 + pad},${yBack} ${g.bx1 + pad},${g.yBottom + pad} ${g.x1},${g.yBottom + pad}`;
        this.els.sideDust.setAttribute('points', side);
        this.els.sideShade.setAttribute('points', side);

        this.els.surface.setAttribute('points', `${g.x0},${yFront} ${g.x1},${yFront} ${g.bx1},${yBack} ${g.bx0},${yBack}`);
        this.els.clipBody.setAttribute('points',
            `${g.x0 - pad},${yFront} ${g.x0},${yFront} ${g.bx0},${yBack} ${g.bx1 + pad},${yBack} ${g.bx1 + pad},${g.yBottom + pad} ${g.x0 - pad},${g.yBottom + pad}`);

        // Dust drops in from the chute in the middle, so it piles up in a mound
        const heapHeight = Math.min(40, fraction * (g.yBottom - g.yTop) * 0.6);
        const heap = heapHeight < 1 ? '' : this.heapPath(g.cx, yFront + g.dy / 2, 165, 26, heapHeight);
        this.els.heap.setAttribute('d', heap);
        this.els.clipHeap.setAttribute('d', heap);
    },

    geometry() {
        const { x0, x1, yTop, yBottom, dx, dy, bulge } = BAG_GEOMETRY;
        const yMid = (yTop + yBottom) / 2;
        const bx0 = x0 + dx, bx1 = x1 + dx, byTop = yTop + dy, byBottom = yBottom + dy;
        return {
            x0, x1, yTop, yBottom, dx, dy, bx0, bx1, byTop, byBottom,
            cx: (x0 + bx1) / 2,
            cyTop: yTop + dy / 2,
            front: `M${x0},${yTop} L${x1},${yTop} Q${x1 + bulge},${yMid} ${x1},${yBottom} Q${(x0 + x1) / 2},${yBottom + bulge} ${x0},${yBottom} Q${x0 - bulge},${yMid} ${x0},${yTop} Z`,
            side: `M${x1},${yTop} L${bx1},${byTop} Q${bx1 + bulge},${yMid + dy} ${bx1},${byBottom} L${x1},${yBottom} Q${x1 + bulge},${yMid} ${x1},${yTop} Z`,
            top: `M${x0},${yTop} L${bx0},${byTop} L${bx1},${byTop} L${x1},${yTop} Z`,
            outline: `M${x0},${yTop} L${bx0},${byTop} L${bx1},${byTop} Q${bx1 + bulge},${yMid + dy} ${bx1},${byBottom} L${x1},${yBottom} Q${(x0 + x1) / 2},${yBottom + bulge} ${x0},${yBottom} Q${x0 - bulge},${yMid} ${x0},${yTop} Z`,
            seams: `M${x0 + 10},${yTop + 10} L${x1 - 10},${yTop + 10} M${x0 + 10},${yTop + 10} Q${x0 - bulge + 10},${yMid} ${x0 + 10},${yBottom - 6} M${x1 - 10},${yTop + 10} Q${x1 + bulge - 10},${yMid} ${x1 - 10},${yBottom - 6}`
        };
    },

    heapPath(cx, cy, rx, ry, h) {
        return `M${cx - rx},${cy} C${cx - rx * 0.55},${cy - h * 0.9} ${cx - rx * 0.3},${cy - h} ${cx},${cy - h} ` +
               `C${cx + rx * 0.3},${cy - h} ${cx + rx * 0.55},${cy - h * 0.9} ${cx + rx},${cy} ` +
               `A${rx} ${ry} 0 0 1 ${cx - rx},${cy} Z`;
    },

    // Lift loop sewn to the top edge between xa and xb
    loop(xa, xb, y) {
        const mid = (xa + xb) / 2;
        const d = `M${xa},${y} L${xa},${y - 33} Q${xa},${y - 60} ${mid},${y - 60} Q${xb},${y - 60} ${xb},${y - 33} L${xb},${y}`;
        return `<path d="${d}" class="bag-loop-edge"/><path d="${d}" class="bag-loop"/>`;
    },

    buildParticles() {
        const g = this.g;
        const random = mulberry32(2024);
        let markup = '';
        for (let i = 0; i < BAG_GEOMETRY.particles; i++) {
            const x = (g.x0 - 15 + random() * (g.bx1 - g.x0 + 30)).toFixed(1);
            const y = (g.byTop - 10 + random() * (g.yBottom - g.byTop + 30)).toFixed(1);
            const color = SAWDUST_COLORS[Math.floor(random() * SAWDUST_COLORS.length)];
            const opacity = (0.45 + random() * 0.5).toFixed(2);
            if (random() < 0.15) {
                // Wood shaving
                const angle = Math.floor(random() * 180);
                markup += `<ellipse cx="${x}" cy="${y}" rx="${(3 + random() * 5).toFixed(1)}" ry="${(0.8 + random() * 1.2).toFixed(1)}" ` +
                          `transform="rotate(${angle} ${x} ${y})" fill="${color}" opacity="${opacity}"/>`;
            } else {
                markup += `<circle cx="${x}" cy="${y}" r="${(0.7 + random() * 1.6).toFixed(1)}" fill="${color}" opacity="${opacity}"/>`;
            }
        }
        return markup;
    },

    buildScale(capacityYd3) {
        const g = this.g;
        let markup = `<text x="${g.x0 - 42}" y="${g.yTop - 30}" text-anchor="end" class="bag-scale-unit">yd³</text>`;
        for (let i = 0; i <= 4; i++) {
            const y = g.yBottom - (i / 4) * (g.yBottom - g.yTop);
            markup += `<line x1="${g.x0 - 34}" y1="${y}" x2="${g.x0 - 18}" y2="${y}" class="bag-scale-tick"/>`;
            markup += `<text x="${g.x0 - 42}" y="${y + 7}" text-anchor="end" class="bag-scale-label">${(i / 4 * capacityYd3).toFixed(2)}</text>`;
        }
        return markup;
    },

    buildMarkup(capacityYd3) {
        const g = this.g;
        return `
        <defs>
            <clipPath id="bag-clip-outline"><path d="${g.outline}"/></clipPath>
            <clipPath id="bag-clip-front"><path d="${g.front}"/></clipPath>
            <clipPath id="bag-clip-side"><path d="${g.side}"/></clipPath>
            <clipPath id="bag-clip-sawdust">
                <polygon id="bag-clipBody"/>
                <path id="bag-clipHeap"/>
            </clipPath>
            <linearGradient id="bag-grad-front" gradientUnits="userSpaceOnUse" x1="0" y1="${g.yTop}" x2="0" y2="${g.yBottom}">
                <stop offset="0" stop-color="#d9b27c"/>
                <stop offset="1" stop-color="#a87b45"/>
            </linearGradient>
            <linearGradient id="bag-grad-side" gradientUnits="userSpaceOnUse" x1="0" y1="${g.byTop}" x2="0" y2="${g.byBottom}">
                <stop offset="0" stop-color="#b98c55"/>
                <stop offset="1" stop-color="#7f5a30"/>
            </linearGradient>
            <radialGradient id="bag-grad-heap" cx="0.42" cy="0.3" r="0.75">
                <stop offset="0" stop-color="#f3ddb0"/>
                <stop offset="1" stop-color="#dcb67f"/>
            </radialGradient>
            <linearGradient id="bag-grad-steel" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0" stop-color="#4b5563"/>
                <stop offset="0.45" stop-color="#d1d5db"/>
                <stop offset="1" stop-color="#4b5563"/>
            </linearGradient>
            <linearGradient id="bag-grad-sheen" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0" stop-color="#ffffff" stop-opacity="0.10"/>
                <stop offset="0.35" stop-color="#ffffff" stop-opacity="0"/>
                <stop offset="0.85" stop-color="#ffffff" stop-opacity="0.04"/>
                <stop offset="1" stop-color="#ffffff" stop-opacity="0.12"/>
            </linearGradient>
            <pattern id="bag-weave" width="10" height="10" patternUnits="userSpaceOnUse">
                <rect width="10" height="10" fill="#6b7280" fill-opacity="0.05"/>
                <path d="M0 5H10M5 0V10" stroke="#6b7280" stroke-opacity="0.14" stroke-width="1.2"/>
            </pattern>
            <filter id="bag-blur" x="-20%" y="-50%" width="140%" height="200%"><feGaussianBlur stdDeviation="10"/></filter>
        </defs>

        <!-- Floor shadow -->
        <ellipse cx="${g.cx}" cy="${(g.yBottom + g.byBottom) / 2 + 10}" rx="300" ry="50" fill="#000" opacity="0.18" filter="url(#bag-blur)"/>

        <!-- Back of the bag, seen through the fabric -->
        <g class="bag-back">
            ${this.loop(g.bx0 + 14, g.bx0 + 64, g.byTop)}
            ${this.loop(g.bx1 - 64, g.bx1 - 14, g.byTop)}
            <path d="M${g.bx0},${g.byTop} L${g.bx0},${g.byBottom} L${g.bx1},${g.byBottom} M${g.x0},${g.yBottom} L${g.bx0},${g.byBottom}" class="bag-hidden-edge"/>
        </g>

        <!-- Dust collector discharge chute -->
        <rect x="${g.cx - 28}" y="-10" width="56" height="${g.cyTop - 40}" fill="url(#bag-grad-steel)"/>
        <rect x="${g.cx - 38}" y="${g.cyTop - 80}" width="76" height="12" rx="2" fill="#4b5563"/>

        <!-- Sawdust -->
        <g id="bag-sawdust" clip-path="url(#bag-clip-outline)">
            <g clip-path="url(#bag-clip-front)">
                <rect id="bag-frontDust" x="${g.x0 - 40}" width="${g.x1 - g.x0 + 80}" fill="url(#bag-grad-front)"/>
            </g>
            <g clip-path="url(#bag-clip-side)">
                <polygon id="bag-sideDust" fill="url(#bag-grad-side)"/>
            </g>
            <polygon id="bag-surface" fill="#dcb680"/>
            <path id="bag-heap" fill="url(#bag-grad-heap)"/>
            <g clip-path="url(#bag-clip-sawdust)">${this.buildParticles()}</g>
            <g clip-path="url(#bag-clip-side)">
                <polygon id="bag-sideShade" fill="#000000" opacity="0.25"/>
            </g>
        </g>

        <!-- Fabric: translucent so the sawdust inside is visible -->
        <path d="${g.side}" fill="url(#bag-weave)"/>
        <path d="${g.side}" fill="#000000" opacity="0.05"/>
        <path d="${g.top}" fill="url(#bag-weave)"/>
        <path d="${g.front}" fill="url(#bag-weave)"/>
        <path d="${g.front}" fill="url(#bag-grad-sheen)"/>
        <path d="${g.seams}" fill="none" class="bag-seam"/>
        <path d="${g.side} ${g.top} ${g.front}" fill="none" class="bag-edge"/>

        <!-- Fill spout tied around the chute -->
        <path d="M${g.cx - 45},${g.cyTop} L${g.cx - 45},${g.cyTop - 62} L${g.cx + 45},${g.cyTop - 62} L${g.cx + 45},${g.cyTop} A45 13 0 0 1 ${g.cx - 45},${g.cyTop} Z"
              fill="url(#bag-weave)" class="bag-edge"/>
        <rect x="${g.cx - 49}" y="${g.cyTop - 66}" width="98" height="10" rx="3" fill="#9ca3af"/>

        <!-- Front lift loops -->
        ${this.loop(g.x0 + 14, g.x0 + 64, g.yTop)}
        ${this.loop(g.x1 - 64, g.x1 - 14, g.yTop)}

        <!-- Volume scale -->
        ${this.buildScale(capacityYd3)}
        `;
    }
};

// Small seeded PRNG so the sawdust texture looks the same on every refresh
function mulberry32(seed) {
    return function() {
        seed = seed + 0x6D2B79F5 | 0;
        let t = Math.imul(seed ^ seed >>> 15, 1 | seed);
        t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
        return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
}

export default BagView;
