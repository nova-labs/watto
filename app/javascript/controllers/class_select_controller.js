import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="class-select"
export default class extends Controller {
	static targets = ["selectBox", "notificationArea"]

	select(event){
		// pull the selected option from the selectBox target
		// iff selected option is class, then...
		// pull the signoffs value from the selected option
		// put that data in the notificationArea target to display
	}
}
