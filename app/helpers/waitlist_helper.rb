module WaitlistHelper
  def waitlist_google_sheet_url
    "https://docs.google.com/spreadsheets/d/#{ENV['WAITLIST_GOOGLE_SHEET_ID']}"
  end

  def waitlist_field_quips_for(field)
    {
      name: [
        "The name you'd shout across a loud shop floor.",
        "Whatever you write here may be engraved on a shop plaque someday.",
      ],
      email: [
        "We won't sell it. Not even for a stack of walnut.",
        "We promise not to use this to sign you up for woodworking newsletters. Unless you ask.",
        "We'll only use this when Slack fails us… which is rare, but loud.",
        "Add your burner if you must, but don’t blame us if you miss a class.",
      ],
      slack: [
        "Slack us your Slack so we can Slack you on Slack.",
        "For when email ghosts us but Slack still delivers.",
        "Include just the handle. We already know it starts with @.",
        "Used for important stuff: class updates, memes, and mild encouragement.",
        "Our way of saying 'hey' faster than USPS and with fewer stamps.",
        "This is how you'll hear about class changes before they become rumors.",
      ]
    }[field].sample
  end

  def waitlist_callouts
    [
      {
        title: "Class Is in Session (Probably)",
        description: "Welcome to the chaotic neutral registry of Nova Labs classes. Some of them fill up. Some of them don’t. Some of them involve torches. If a class has a waitlist, you can join it. If not, well, wander the listings like a caffeinated archaeologist and see what turns up."
      },
      {
        title: "Sign Up or Sign Off",
        description: "This is your hub for all things educational and moderately flammable. Sign-off classes are the ones that let you use dangerous tools. Project classes are where you make things you’ll show your friends once. Some have waitlists. Some don’t. It’s all very exciting in a paperwork kind of way."
      },
      {
        title: "An Orderly Queue of Curiosity",
        description: "Ah yes, learning — the gateway to operating terrifying equipment. If the class you're eyeing has a waitlist, feel free to join it. If not, don’t worry — it might still be around when you're done reading this paragraph. Might."
      },
      {
        title: "Enroll Responsibly",
        description: "Nova Labs offers a variety of classes for your brain, your hands, and your growing collection of niche hobbies. If there's a waitlist, hop on. If there isn’t, take it as a sign from the universe, or perhaps just an oversight."
      },
      {
        title: "The Hitchhiker’s Guide to Sign-offs",
        description: "This is where you go to get authorized, educated, and possibly irradiated (just kidding). Some classes require waitlists. Some don’t. If you feel confused, you’re doing it right."
      },
      {
        title: "Danger, Learning Ahead",
        description: "Welcome to the class signup page. Here, you’ll find courses that might teach you to sew leather, cut steel, or wield a soldering iron with *mild* competence. Waitlists exist for some classes. For others, you simply need to show up before the people with faster internet connections."
      },
      {
        title: "Formal Instruction for Informal Makers",
        description: "At Nova Labs, we encourage lifelong learning — mostly so you don’t accidentally void your fingers with a table saw. Some classes fill up and offer a polite digital queue. Others are free-floating like unattended toddlers in a bounce house."
      },
      {
        title: "Welcome to the Cult of Competence",
        description: "Join us in acquiring marginally dangerous skills under the supervision of people with clipboards. Some classes require waitlist signup. Others are just sitting there, waiting patiently like a sad puppy. Click accordingly."
      },
      {
        title: "Learn, Wait, Repeat",
        description: "This is where you sign up for classes. Some have waitlists, some don’t. The important thing is you tried. And sometimes that’s enough. Other times, you need to click faster. Either way, we believe in you."
      },
      {
        title: "The Path to Enlightenment is Behind a Bandsaw",
        description: "Looking to level up your maker skills? You’ve come to the right place. Some classes require sign-off. Some require patience. All require clicking. Start your journey here, and try not to get splinters."
      },
      {
        title: "The Fellowship of the Sign-off",
        description: "Some classes fill up faster than a sharp chisel on soft pine — those use waitlists. Others are posted and open to anyone. If you see one you want, don’t wait until the glue sets."
      },
      {
        title: "Cut Once, Sign Off First",
        description: "Before you can create with confidence (and safety), some classes require a sign-off. These fill up fast and use a waitlist. Other classes? They're first come, first crafted."
      },
      {
        title: "The Sawdust Summit",
        description: "This is the gathering place for curious makers. Popular sign-off classes may have waitlists. Others are posted like raw materials — grab them before someone else does."
      },
      {
        title: "Joinery and the Joy of Queuing",
        description: "Sign-off classes help you avoid unfortunate accidents. They're required, popular, and often waitlisted. Other classes are posted and available to whoever acts first."
      },
      {
        title: "The Waiting Bench",
        description: "Some classes are so loved, you’ll need to get in line — literally. Others are available without waitlists, like a lonely tool hoping to be picked up. Act fast either way — the shop doesn't wait."
      },
      {
        title: "Spark It, Don’t Wing It",
        description: "Classes that involve extra safety or certification often require a sign-off. They fill up fast, so waitlists help. Other classes are posted directly — they won't stay open forever."
      },
      {
        title: "Waiting to Weld",
        description: "You can't just jump into advanced tools without the training. Some classes require a sign-off and fill up fast — those have waitlists. Others are first come, first served. No sparks necessary."
      },
      {
        title: "The Queue is Forged",
        description: "Some classes are forged in popularity — and waitlists. Others are posted like opportunities: fleeting, valuable, and available if you click quickly."
      },
      {
        title: "Lathe to the Party",
        description: "Our most in-demand classes often use waitlists to keep things fair. Others are posted without them, and they go fast. Like, 'refresh-your-browser' fast."
      },
      {
        title: "The Anvil Doesn’t Wait",
        description: "Classes that involve tools, techniques, or certification may require a sign-off. That means waitlists. Other classes are posted like open invitations — yours if you act quickly."
      },
      {
        title: "Thread Carefully",
        description: "Some classes require a sign-off before you're let loose on the equipment. These tend to fill up, so waitlists keep things fair. Other classes are available to anyone — just don’t drag your feet."
      },
      {
        title: "The Stitchuation Room",
        description: "Popular classes may have waitlists to manage the crowd. Others are posted first-come, and are yours to grab. If it looks interesting, jump on it before it disappears like socks in the laundry."
      },
      {
        title: "Pins and Needles (Mostly Needles)",
        description: "Some classes fill up fast and use waitlists to keep order. Others are wide open until someone claims them. If you're the type to say 'I'll do it later' — this is your warning."
      },
      {
        title: "Quilt While You're Ahead",
        description: "High-demand classes often require waitlists. Other classes are just sitting there, waiting to be picked. Kind of like that project you started two months ago. You know the one."
      },
      {
        title: "Sew Many Classes, Sew Little Time",
        description: "Some classes are waitlisted because they’re just that good. Others are posted and ready for whoever gets there first. Choose your adventure, one stitch (or click) at a time."
      },
      {
        title: "The Hitchhiker’s Guide to Sign-offs",
        description: "This is where you go to get authorized, educated, and possibly irradiated (just kidding). Some classes require waitlists. Others don’t. If you feel confused, you’re doing it right."
      },
      {
        title: "Sign Up or Sign Off",
        description: "This is your hub for all things educational and moderately flammable. Some classes require sign-off. Some don’t. If there's a waitlist, that means it’s a hot ticket. Others you can just grab."
      },
      {
        title: "Join the Waitlist, Luke",
        description: "Some classes are strong with the Force (and also extremely popular). These require waitlists to keep peace in the galaxy. Others appear suddenly — no waitlist needed, just a well-timed click."
      },
      {
        title: "You've Got Class",
        description: "Some classes fill up before you’ve finished reading this sentence. For those, a waitlist awaits. Others are hanging out, hoping someone notices them. Like you. Today."
      },
      {
        title: "From Waitlist to Great List",
        description: "If a class has a waitlist, it’s because it fills up faster than a flash sale on dice sets. Others are posted as-is, and if you blink, they might be gone. Sign up when you see one you like."
      },
      {
        title: "Behold! The Learning Board",
        description: "This is where classes appear — some in high demand, with waitlists. Others are open and available, waiting to be claimed. Think of it like a treasure chest. But with safety glasses."
      },
      {
        title: "Enrollment Roll Initiative",
        description: "Some classes require waitlists — it's like rolling for initiative at a table full of rogues. Others are just out there, unguarded. First come, first cast. Choose wisely."
      },
      {
        title: "It’s Dangerous to Go Alone — Take This Class",
        description: "Some classes require training before you can proceed. Those fill up fast and use waitlists. Others are open to anyone brave enough to click. You don’t even need a sword."
      },
      {
        title: "Dangerously Educational",
        description: "If it’s popular or tool-related, it probably has a waitlist. If not, it’s first come, first teach. Either way, we recommend showing up with curiosity and close-toed shoes."
      },
      {
        title: "Timey-Wimey Learning Stuff",
        description: "Some classes fill up in a flash, so we use waitlists to keep timelines sane. Others just appear like rogue time anomalies. You’ll want to act fast before they dematerialize."
      },
      {
        title: "An Orderly Queue of Curiosity",
        description: "Some classes are so popular they get their own waitlists. Others are simply out there, just waiting to be noticed. Either way, your brain wins."
      },
      {
        title: "Class Is in Session (Probably)",
        description: "This is the chaotic neutral registry of classes. Some fill up and use waitlists. Others don’t. Think of this as a bingo board of opportunity — keep checking, keep clicking."
      },
      {
        title: "Learn, Wait, Repeat",
        description: "Some classes have waitlists. Others don’t. That’s basically the whole deal. Sign up, check back, and try not to overthink it."
      },
      {
        title: "Build Cool Stuff, Responsibly",
        description: "Some tools require training. Some classes fill up immediately. That’s why we have waitlists. Others are open — no wait, just click, show up, and build something great."
      },
      {
        title: "Welcome to the Cult of Competence",
        description: "Join us in acquiring marginally dangerous skills under the supervision of people with clipboards. Some classes require waitlist signup. Others are just sitting there, waiting patiently like a sad puppy. Click accordingly."
      },
      {
        title: "Formal Instruction for Informal Makers",
        description: "We encourage lifelong learning — mostly so you don’t accidentally void your fingers with a table saw. Some classes fill up and offer a polite digital queue. Others are free-floating like unattended toddlers in a bounce house."
      }
    ].sample
  end
end

