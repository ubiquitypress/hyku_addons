export default class SelectWorkType {
	/**
	 * Initializes the class in the context of an individual table button
	 * @param {jQuery} button the table button that this class represents
	 */
	constructor(button) {
		this.target = button.data('target')
		this.modal = $(this.target)
		this.form = this.modal.find('form.hyku_addons-new-work-select')
		this.type = "single" // Set a default

		button.on('click', (e) => {
			e.preventDefault()

			this.modal.modal()
			this.type = button.data('create-type')
			this.form.on('submit', this.routingLogic.bind(this))
		});

		// remove the routing logic when the modal is hidden
		this.modal.on('hide.bs.modal', (e) => {
			this.form.unbind('submit')
		});
	}

	// when the form is submitted route to the correct location
	routingLogic(e) {
		e.preventDefault()

		if (this.destination() === undefined) {
			return false
		}

		window.location.href = this.destination()
	}

	// Each input has two attributes that contain paths, one for the batch and one
	// for a single work. So, given the value of 'this.type', return the appropriate path.
	destination() {
		let admin_set_id = this.form.find('select').val()
		let url = this.form.find('input[type="radio"]:checked').data(this.type)

		if (admin_set_id !== undefined) {
			url += "&admin_set_id=" + admin_set_id
		}

		return url
	}
}
