import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="class-select"
export default class extends Controller {
	static targets = ["signoffSelector", "notificationArea"]

	select(event){
		// pull the selected option from the selectBox target
		// iff selected option is class, then...
		// pull the signoffs value from the selected option
		// put that data in the notificationArea target to display
		console.log("triggered", event)
		const selected_value = event.target.value
		if selected_value.hasAttribute("isClass"){
			signoff_list = selected_value.signoffs
			notifcationAreaTarget.innerHTML=signoff_list
		}
	}
}
