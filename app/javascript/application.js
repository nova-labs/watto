// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.sidebarToggler = function(event) {
  const sidebarToggle = document.body.querySelector('#sidebarToggle');
  event.preventDefault();
  document.body.classList.toggle('sb-sidenav-toggled');
}

