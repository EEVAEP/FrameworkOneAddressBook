document.addEventListener("DOMContentLoaded", function () {
    	document.querySelectorAll(".delete").forEach(function(button) {
        	button.addEventListener("click", function() {
            		var contactId = this.getAttribute("data-id");
            		console.log("Contact ID to delete:", contactId);

            		if (contactId) {
                		document.getElementById("confirmDeleteButton").setAttribute("data-contact-id", contactId);
            		} else {
                		alert("Error: Contact ID is missing or undefined.");
            		}
        	});
    	});

    	document.getElementById("confirmDeleteButton").addEventListener("click", function () {
        	const contactId = this.getAttribute("data-contact-id");
        	console.log("Contact ID from confirm button:", contactId);

        	if (!contactId) {
            		alert("Error: No contact ID available for deletion.");
            		return;
        	}

        	$.ajax({
            		type: "POST",
            		url: `../../model/UserService.cfc?method=deleteContact&contactId=${contactId}`,
            		dataType: "json",

            		success: function (response) {
				console.log("AJAX response:", response);
                		if (response.STATUS == "success") {	
					console.log("Deleting contact...");
			
                    
                    			const deleteModalElement = document.getElementById("deleteConfirmModal");
                    			const deleteModal = bootstrap.Modal.getInstance(deleteModalElement);
                    			if (deleteModal) {
                        			deleteModal.hide();
                    			}
					document.body.classList.remove('modal-open');
                    			const backdrop = document.querySelector('.modal-backdrop');
                    			if (backdrop) {
                        			backdrop.remove();
                    			}
					const rowToDelete = document.querySelector(`tr[data-id="${contactId}"]`);
                    			if (rowToDelete) {
                        			rowToDelete.remove();
                        			console.log("Row deleted:", rowToDelete);
                    			} else {
                        			console.log("Row not found for deletion");
                    			}
                    
                		} 
	            
			}
           	});
    	});
});
