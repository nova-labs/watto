import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="batch-update-tool"
export default class extends Controller {
  static targets = [ "searchInput", "search", "contacts", "signoffSelector", "notificationArea" ]

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

  // pull the selected option from the selectBox target
  // iff selected option is class, then...
  // pull the signoffs value from the selected option
  // put that data in the notificationArea target to display
  select(event) {    
    console.log("triggered", event)
    // I can get the selector as a Stimulus target or as the event target. 
    // I'm not sure which is better SWE. 
    // Getting it as the event target makes it easier to extend to other selectors, including accidentally
    const selector = event.target
    const selected_value = selector[selector.selectedIndex]
    console.log("selected_value", selected_value)
    console.log("is class", selected_value.hasAttribute("isClass"))
    if (selected_value.hasAttribute("isClass")){
      const signoff_list = selected_value.getAttribute("signoffs")
      console.log("signoffs", signoff_list)
      console.log("sour ouch", this.notificationAreaTarget)
      this.notificationAreaTarget.innerHTML=signoff_list
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
