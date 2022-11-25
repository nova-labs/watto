import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="batch-update-tool"
export default class extends Controller {
  static targets = [ "searchInput", "search", "contacts", "signoffSelector", "notificationArea", "notificationHeader" ]

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
    console.log("sweet ouch", event)
    // I can get the selector as a Stimulus target or as the event target. 
    // I'm not sure which is better SWE. 
    // Getting it as the event target makes it easier to extend to other selectors, including accidentally
    const selector = event.target
    const selected_value = selector[selector.selectedIndex]
    if (selected_value.hasAttribute("isClass")){
      this.notificationHeaderTarget.style.display="inline"
      const signoff_list = this._parseSignoffList(selected_value.getAttribute("signoffs"))
      this.notificationAreaTarget.innerHTML=this._generateNotification(signoff_list)
    }
    else{
      this.notificationHeaderTarget.style.display="none"
      this.notificationAreaTarget.innerHTML = ""
    }
  }

  _generateNotification(signoff_list){
    let notification_HTML = ""
    let list_HTML = []
    signoff_list.forEach(element =>{
      let signoff_type = element.match(/\[(.*)\]/)[1]
      list_HTML.push(`<li class="signoff-list-element ${signoff_type}">${element.trim()}</li>`)
    })
    return list_HTML.join("")
  }

  _parseSignoffList(signoff_list_string){
    let list = signoff_list_string.replaceAll("\"", "") // cut any included quotation marks
    list = list.replace(/^\[/, "") // strip leading bracket
    list = list.replace(/\]%/, "") // strip trailing bracket
    list = list.split(",")
    return list
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
