import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="batch-update-tool"
export default class extends Controller {
  static targets = [ "searchInput", "search", "contacts" ]

  input(event) {
    if (event.target.value.length > 2) {
      console.log("mega ouch", event);
      const value = event.target.value
      const url = event.target.getAttribute("data-url")
      fetch(`${url}?q=${value}`).then((response) => response.text())
        .then(data => {
          this.searchTarget.innerHTML = data;
        })

    } else {
      this.searchTarget.innerHTML = "";
    }
  }

  add(event) {
    event.preventDefault();
    document.getElementById("contact_search_list").innerHTML = "";
    console.log("spicy ouch", event);
    document.getElementById("contact_search_list").innerHTML = "";
    const value = event.target.getAttribute("data-value");
    const url = event.target.getAttribute("data-url");
    fetch(`${url}?id=${value}`)
      .then((response) => response.text())
      .then(data => {
        this.contactsTarget.insertAdjacentHTML("beforeend", data);
        this.searchTarget.innerHTML = "";
        this.searchInputTarget.removeAttribute("required");
        this.searchInputTarget.value = "";
      })
  }
  remove(event) {
    event.preventDefault();
    console.log("never ouch", event);
    event.target.closest(".contact-fields").remove()
  }
}
