import { Controller } from "@hotwired/stimulus"

export default class extends Controller{
	static targets= ["checkboxArea"]

	select(event){
		console.log("sweet ouch", event)
		const selector = event.target
		const selected_value = selector[selector.selectedIndex]
		const signoffs = this._parseSignoffList(selected_value.getAttribute("signoffs"))
		console.log("signoffs", signoffs)
		const checkboxes = [].slice.call(this.checkboxAreaTarget.children).filter(el => el.nodeName == "INPUT") // gets a list of all input elements in the checkboxArea
		checkboxes.forEach(box =>{
			if (signoffs.includes(box.name)) {
				box.checked=true;
				console.log("checked", box.name);
			} else {
				box.checked=false;
				console.log("unchecked", box.name)
			}
		})
	}

  	// I know copy pasting this from batch_update_tool_controller.js is bad
  	// practice, but I don't feel like trying to figure out how to put this 
  	// function in its own file and then reference it here and there
  	_parseSignoffList(signoff_list_string){
	    console.log("parsing", signoff_list_string)
	    let list = signoff_list_string.replaceAll("\"", "") // cut any included quotation marks
	    list = list.replace(/^\[/, "") // strip leading bracket
	    list = list.replace(/\]$/, "") // strip trailing bracket
	    list = list.split(",")
	    for (var i = list.length - 1; i >= 0; i--) {
	     	list[i] = list[i].trim()
	    } 
	    return list
  }
}