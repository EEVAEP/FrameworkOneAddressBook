
$(document).ready(function() {
	var contactId;

	var title=$('#title');
	var firstName=$('#firstName');
	var lastName=$('#lastName');
	var gender=$('#gender');
	var cntdob=$('#dob');
	var photo=$('#photo');
	var address=$('#address');
	var street=$('#street');
	var pincode=$('#pincode');
	var email=$('#email');
	var phone=$('#phone');
	var hobbies=$('#hobbies');
	var isPublic = $('#isPublic')

	$('#createContactBtn').on('click',function(){
		document.getElementById("createContactModalLabel").innerText = "CREATE CONTACT";
		$('#contactForm').trigger('reset');
		$('#saveContactBtn').show();
		$('#updateContactBtn').hide();
		$('#thumbnailPreview').empty();
		
	});
	

	

	$(document).on('click', '.edit', function() {
		document.getElementById('saveContactBtn').style.display="none";
		$('#updateContactBtn').show();
		$('#errorMessages').empty();
		
		contactId = $(this).data('id');
		console.log(contactId);

		$('#contactId').val(contactId);

		$.ajax({
			url:'../../model/UserService.cfc?method=getDataById',
			type:'POST',
			data:{
				contactId:contactId
			},
			success:function(response){
				const data= JSON.parse(response);
				console.log(data);
				 
        		$('#titleid').val(data.titleid);
				$('#firstName').val(data.firstname);
				$('#lastName').val(data.lastname);
				$('#gender').val(data.genderid);

				const dob=data.dob;
				let dobDate = new Date(dob);
				let formattedDob = dobDate.toISOString().split('T')[0];
				console.log(formattedDob);
				$('#dob').val(formattedDob);

				$('#email').val(data.email);
				$('#phone').val(data.phone);
				$('#address').val(data.address);
				$('#street').val(data.street);
				$('#pincode').val(data.pincode);

				const photopath = data.photo;
				console.log(photopath);
				
				const contactDiv = document.getElementById('thumbnailPreview');
				contactDiv.innerHTML = '';
				const imgElement = document.createElement('img');
				imgElement.src = photopath;

				imgElement.alt = 'Placeholder Image';
        			imgElement.style.width = '65px'; 
        			imgElement.style.height = '65px';
				contactDiv.appendChild(imgElement);

				const hobbies = data.hobby_ids.split(",");
				$('#hobbies').val(hobbies);

				$('#isPublic').val(data.is_public);
				
				if(data.is_public == '1') {
                			$('#isPublic').prop('checked', true);  
            			} else {
                			$('#isPublic').prop('checked', false); 
            			}
			},
			error:function(){
				console.log("Request Failed");
			}
		});


		document.getElementById("createContactModalLabel").innerText = "EDIT CONTACT";
               	
	});


	


	$(document).on('click', '.view', function() {
		
		contactId = $(this).data('id');
		console.log(contactId);
		$.ajax({
			url:'../../model/UserService.cfc?method=getDataById',
			type:'POST',
			data:{
				contactId:contactId
			},
			success:function(response){
				const data=JSON.parse(response);
				console.log(data);
				
				let dob = new Date(data.dob);
				let day = String(dob.getDate()).padStart(2, '0'); 
				let month = String(dob.getMonth() + 1).padStart(2, '0'); 
				let year = dob.getFullYear();
				let formattedDob = `${day}-${month}-${year}`;
				
				$('#viewPhoto').attr('src', data.photo);
				$('#viewName').text(data.firstname + " " + data.lastname);
				$('#viewFirstName').text(data.firstname);
				$('#viewLastName').text(data.lastname);
				$('#viewDob').text(formattedDob);
				$('#viewAddress').text(data.address);
				$('#viewStreet').text(data.street);
				$('#viewPincode').text(data.pincode);
				$('#viewEmail').text(data.email);
				$('#viewPhone').text(data.phone);	
				$('#viewTitle').text(data.titlename);
				$('#viewGender').text(data.gendername);
				const hobbies = data.hobby_names.split(",")
				$('#viewHobbies').text(hobbies.join(","));

				
			},
			error:function(){
				console.log("Request Failed");
			}
		});
	});

});

/*function addOnError(errors) {
	$('#errorMessages').empty();

	 errors.forEach(function(error) {
        	$('#errorMessages').append('<div class="alert alert-danger">' + error + '</div>');
 	});
}*/



$(document).on('change', '#photo', function(event) {
    	const file = event.target.files[0];

    	if (file) {
        	const reader = new FileReader();

        	reader.onload = function(e) {
            		const imgElement = document.createElement('img');
            		imgElement.src = e.target.result;
            		imgElement.alt = 'Uploaded Image';
            		imgElement.style.width = '65px';
            		imgElement.style.height = '65px';

            		const contactDiv = document.getElementById('thumbnailPreview');
            		contactDiv.innerHTML = ''; 
            		contactDiv.appendChild(imgElement); 
        	};

        	reader.readAsDataURL(file); 
    	}   
});




	