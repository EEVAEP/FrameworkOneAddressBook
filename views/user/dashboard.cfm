
<cfset variables.title = "">
<cfset variables.firstName = "">
<cfset variables.lastName = "">
<cfset variables.gender = "">
<cfset variables.dob = "">
<cfset variables.photo = "">
<cfset variables.address = "">
<cfset variables.street = "">
<cfset variables.pincode = "">
<cfset variables.email = "">
<cfset variables.phone = "">
<cfset variables.hobbies = "">
<cfset variables.isPublic = "">

<cfset variables.openModal = false>
<cfset variables.errorMessageHtml = "">

<cfif structKeyExists(form, "submit")>
	<cfset isPublic = structKeyExists(form, "isPublic") ? "1" : "0">
	<cfif NOT structKeyExists(form, "hobbies")>
		<cfset temphobbies = "">
	<cfelse>
		<cfset temphobbies = form.hobbies>
	</cfif>
	
	<cfset variables.validationErrorArray = application.userService.validateAddEditContactDetails(title = form.title,
													firstName = form.firstName,
													lastName = form.lastName,
													gender = form.gender,
													dob = form.dob,
													photo = form.photo,
													address  = form.address,
													street = form.street,
													pincode = form.pincode,
													email = form.email,
													phone = form.phone,
													hobbies = temphobbies,
													is_public = isPublic,
													contactId = form.contactId)>
	

	<cfset variables.openModal = arrayLen(variables.validationErrorArray.errors) GT 0>
	<cfif variables.openModal>
		<cfset variables.title = form.title>
		<cfset variables.firstName = form.firstName>
		<cfset variables.lastName = form.lastName>
		<cfset variables.gender = form.gender>
		<cfset variables.dob = form.dob>
		<cfset variables.address = form.address>
		<cfset variables.street = form.street>
		<cfset variables.pincode = form.pincode>
		<cfset variables.email = form.email>
		<cfset variables.phone = form.phone>
		<cfset variables.hobbies = temphobbies>
		<cfset variables.isPublic = isPublic>
        <cfset variables.errorMessageHtml = '<ul><li>'& arrayToList(variables.validationErrorArray.errors, '</li><li>')&'</li></ul>'>
	<cfelse>
		<cfset variables.errorMessageHtml = "">
	</cfif>
</cfif>


<cfif variables.openModal>
	<script>
        document.addEventListener("DOMContentLoaded", function () {
            document.getElementById('updateContactBtn').style.display = 'none';
            var errorMessages = "<cfoutput>#JSStringFormat(variables.errorMessageHtml)#</cfoutput>";
            document.getElementById("errorMessages").innerHTML = errorMessages;
            var modal = new bootstrap.Modal(document.getElementById('createContactModal'));
            modal.show();   
        });
	</script>
</cfif>

<cftry>
	<cfset qryPages = application.userService.getTotalUserDetails()>
	<cfset contactData = []> 
	<cfloop from="1" to="#qryPages.recordCount#" index="i">
		<cfset encryptedId = encrypt(qryPages.idcontact[i], application.encryptionKey, "AES", "Hex")>
		<cfset hobbyIdsArray = ListToArray(qryPages.hobby_ids[i], ",")>
    	<cfset hobbyNamesArray = ListToArray(qryPages.hobby_names[i], ",")>
		<cfset hobbyNamesList = qryPages.hobby_names[i]>
		<cfset hobbiesArray = []>

		<cfloop from="1" to="#ArrayLen(hobbyIdsArray)#" index="j">
            <cfset arrayAppend(hobbiesArray, {
                "hobbyId": hobbyIdsArray[j],
                "hobbyName": hobbyNamesArray[j]
            })>
    		</cfloop>

		<cfset contact = {
            "id" : encryptedId, 
            "titleFullname" : qryPages.titleFullname[i],
            "firstname" : qryPages.firstname[i],
            "lastname" : qryPages.lastname[i],
            "email" : qryPages.email[i],
            "phone" : qryPages.phone[i],
            "photo" : qrypages.photo[i],
            "title" : qryPages.titleid[i],
            "gender" : qryPages.genderid[i],
            "dob" : qryPages.dob[i],
            "address" : qryPages.address[i],
            "street" : qryPages.street[i],
            "pincode" : qryPages.pincode[i],
            "titlename":qryPages.titlename[i],
            "gendername":qryPages.gendername[i],
            "hobbies": hobbiesArray, 
            "hobbiesId": hobbyIdsArray,
            "hobbyNames":hobbyNamesList,
            "publicContact":qryPages.is_public[i]
    		}>
    		<cfset arrayAppend(contactData, contact)>
	</cfloop>
						
	<cfset session.contactData = contactData>
	<cfset jsonContactData = serializeJSON(contactData)>
	<script>
		var jsonContactData = <cfoutput>#serializeJSON(contactData)#</cfoutput>;
    	</script>
	<cfcatch>
		<cfdump var="#cfcatch#">
	</cfcatch>
</cftry>

	
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Address Book Dashboard</title>
    <link href="../../assets/css/styleDashboard.css" rel="stylesheet">
    <link href="../../assets/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <header class="custom-bg text-white d-flex justify-content-between align-items-center py-3 px-4 fixed-top">
            <h2 class="m-0 addresshead">ADDRESS BOOK</h2>
            <a href="../login.cfm?logOut" class="btn btn-light">Logout</a>
        </header>
		<div class="row mt-4 pt-4 align-items-start">
            <div class="col-lg-3 col-md-4 p-5 custom-background d-flex flex-column align-items-center">
                <div class="text-center mb-3">
                    <img src="../../assets/img/user.png" alt="User Image" class="img-thumbnail rounded-circle mt-3" width="140">
                    <h3 class="mt-3">
                    <cfoutput>
                        #session.username#
                    </cfoutput>
                    </h3>
                </div>
                <button type="button" 
                    id="createContactBtn"
                    class="btn btn-primary w-100 mb-4 add" 
                    data-bs-toggle="modal" data-bs-target="#createContactModal">
                    Create Contact
                </button>
            </div>
            <div class="col-lg-9 col-md-8 p-4 mt-2">
                <div class="table-responsive mt-3">
                    <table class="table table-striped">
                        <thead class="table-primary">
                            <tr>
                                <th>PROFILE IMAGE</th>
                                <th>NAME</th>
                                <th>EMAIL ID</th>
                                <th>PHONE NUMBER</th>
                                <th>ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="qryPages">
                                <cfset encryptedId = encrypt(qryPages.idcontact, application.encryptionKey, "AES", "Hex")>
                                <cfset value="">
                                <cfif qryPages.iduser NEQ session.userid AND qryPages.is_public EQ 1>
                                    <cfset value = "disabled bg-secondary">
                                </cfif>
                                <tr data-id="#encryptedId#">
                                    <td>
                                        <img src="#qryPages.photo#" 
                                            alt="Photo of #qryPages.Fullname#"		
                                            width="30" height="30">
                                    </td>
                                    <td>#qryPages.Fullname#</td>
                                    <td>#qryPages.email#</td>
                                    <td>#qryPages.phone#</td>
                                    <td>
                                        <button type="button" 
                                            class="btn btn-sm btn-outline-primary me-2 edit #value#" 
                                            data-bs-toggle="modal" 
                                            data-bs-target="##createContactModal"
                                            data-id="#encryptedId#">
                                            EDIT
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger me-2 delete #value#"
                                            data-bs-toggle="modal" 
                                            data-bs-target="##deleteConfirmModal"
                                            data-id="#encryptedId#" #value#>
                                            DELETE
                                        </button>
                                        <button class="btn btn-sm btn-outline-info view"
                                            data-bs-toggle="modal" 
                                            data-bs-target="##viewContactModal"
                                            data-id="#encryptedId#">
                                            VIEW
                                        </button>
                                        </td>
                                    </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>
			</div>
        </div>
    		
        <div class="modal fade" 
            id="createContactModal"  
            data-bs-backdrop="static" 
            data-bs-keyboard="false" 
            tabindex="-1" 
            role="dialog" 
            aria-labelledby="createContactModalLabel" 
            aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title mx-auto d-block" id="createContactModalLabel">CREATE CONTACT</h5>
                        <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <h6 class="pt-2 text-primary">Personal Contact</h6>
                        <form method="post" id="contactForm" action="" enctype="multipart/form-data">
                            <div class="row">
                                <cfset titleNameQuery = application.userService.getTitleName()>
                                    <div class="form-group col-md-2">
                                        <label for="title">Title</label>
                                        <select class="form-control" id="title" name="title">
                                            <cfoutput query="titleNameQuery">
                                                <option 
                                                    value="#titleNameQuery.idtitle#" 
                                                    <cfif titleNameQuery.idtitle EQ variables.title>selected</cfif>>
                                                        #titleNameQuery.titlename#
                                                </option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                    <div class="form-group col-md-5">
                                        <label for="firstName">First Name</label>
                                        <input type="text" class="form-control" id="firstName" name="firstName" value="<cfoutput>#variables.firstName#</cfoutput>" 
                                        placeholder="Enter First Name" >
                                    </div>
                                    <div class="form-group col-md-5">
                                        <label for="lastName">Last Name</label>
                                        <input type="text" class="form-control" id="lastName" name="lastName" value="<cfoutput>#variables.lastName#</cfoutput>" 
                                            placeholder="Enter Last Name" >
                                    </div>
                            </div>
                            <div class="row">
                                <cftry>
                                    <cfset genderNameQuery = application.userService.getGenderName()>
                                    <div class="form-group col-md-6 pt-2">
                                        <label for="gender">Gender</label>
                                        <select class="form-control" id="gender" name="gender">
                                            <cfoutput query="genderNameQuery">
                                               <option 
                                                    value="#genderNameQuery.idgender#" 
                                                    <cfif genderNameQuery.idgender EQ variables.gender>selected</cfif>>
                                                        #genderNameQuery.gendername#
                                                </option>
                                            </cfoutput>
                                        </select>
                                    </div>
                                    <cfcatch>
                                        <cfdump var="#cfcatch#">
                                    </cfcatch>
                                </cftry>
                                <div class="form-group col-md-6 pt-2">
                                    <label for="dob">Date of Birth</label>
                                    <input type="date" class="form-control" id="dob" name="dob" value="<cfoutput>#variables.dob#</cfoutput>">
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group col-md-6 pt-2">
                                    <label for="photo">Upload Photo</label>
                                    <input type="file" class="form-control-file" id="photo" name="photo">
                                </div>
                                <div id="thumbnailPreview" class="form-group col-md-6 pt-2" >
                                </div>
                            </div>
                            <h6 class="pt-3 text-primary">Contact Details</h6>
                            <div class="form-group pt-1">
                                <label for="address">Address</label>
                                <input type="text" class="form-control" id="address" name="address" placeholder="Enter Address" value="<cfoutput>#variables.address#</cfoutput>">
                            </div>
                            <div class="form-group pt-1">
                                <label for="address">Street</label>
                                <input type="text" class="form-control" id="street" name="street" placeholder="Enter Address" value="<cfoutput>#variables.street#</cfoutput>">
                            </div>
                            <div class="form-group pt-1">
                                <label for="pincode">Pincode</label>
                                <input type="text" class="form-control" id="pincode" name="pincode" placeholder="Enter Pincode" value="<cfoutput>#variables.pincode#</cfoutput>">
                            </div>
                            <div class="form-group pt-1">
                                <label for="email">Email</label>
                                <input type="email" class="form-control" id="email" name="email" placeholder="Enter Email" value="<cfoutput>#variables.email#</cfoutput>">
                            </div>
                            <div class="form-group pt-1">
                                <label for="phone">Phone</label>
                                <input type="tel" class="form-control" id="phone" name="phone" placeholder="Enter Phone Number" value="<cfoutput>#variables.phone#</cfoutput>">
                            </div>
                            <div class="form-group col-md-6 pt-2">
                                <cfset hobbyQuery = application.userService.getHobbyName()>
                                    <label for="hobbies">Hobbies</label>
                                    <select class="form-control" id="hobbies" name="hobbies" multiple size="5">
                                        <cfoutput query="hobbyQuery">
                                                
                                            <option 
                                                    value="#hobbyQuery.idhobby#" 
                                                    <cfif listFind(variables.hobbies, hobbyQuery.idhobby)>selected</cfif>>
                                                        #hobbyQuery.hobby_name#
                                                </option>
                                        
                                        </cfoutput>
                                    </select>
                            </div>
                            <div class="form-group pt-1">
                                <label for="isPublic" class="form-check-label">Make this contact public:</label>
                                <input type="checkbox" id="isPublic"  name="isPublic" <cfif variables.isPublic EQ "true">checked</cfif>>
                            </div>
                            <div>
                                <button id="saveContactBtn" type="submit" name="submit" class="btn btn-primary mt-3 mb-4 mx-auto col-md-5">Save Contact</button>
                                <button id="updateContactBtn" name="submit" class="btn btn-primary mt-2 mb-4 mx-auto col-md-5">Update Contact</button>
                            </div>
                            <input type="hidden" id="contactId" name="contactId">
                            <div id="errorMessages"></div>
                        </form>
                    </div>
                </div>
            </div>
		</div>
		<div class="modal fade" 
            id="deleteConfirmModal" 
            tabindex="-1" 
            aria-labelledby="deleteConfirmLabel" 
            aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title mx-auto d-block" id="deleteConfirmLabel">CONFIRM DELETION</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        Are you sure you want to delete this contact?
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" id="confirmDeleteButton">Delete</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal fade" 
            id="viewContactModal"
            data-bs-backdrop="static" 
            data-bs-keyboard="false" 
            tabindex="-1" 
            aria-labelledby="viewContactModalLabel" 
            aria-hidden="true">
            <div class="modal-dialog modal-lg"> 
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white"> 
                        <h5 class="modal-title mx-auto d-block" id="viewContactModalLabel">VIEW CONTACT DETAILS</h5>
                        <button type="button" class="btn-close btn-close-white"
                                data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                        <div class="col-md-4 text-center">
                            <img id="viewPhoto" src="" alt="Profile Picture" class="img-fluid rounded">
                        </div>
                        <div class="col-md-8">
                            <div class="row">
                                <div class="col-6 text-end label">Name:</div>
                                <div class="col-6 value" id="viewName"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Title:</div>
                                <div class="col-6 value" id="viewTitle"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">First Name:</div>
                                <div class="col-6 value" id="viewFirstName"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Last Name:</div>
                                <div class="col-6 value" id="viewLastName"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Gender:</div>
                                <div class="col-6 value" id="viewGender"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Date of Birth:</div>
                                <div class="col-6 value" id="viewDob"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Address:</div>
                                <div class="col-6 value" id="viewAddress"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Street:</div>
                                <div class="col-6 value" id="viewStreet"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Pincode:</div>
                                <div class="col-6 value" id="viewPincode"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Email:</div>
                                <div class="col-6 value" id="viewEmail"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Phone:</div>
                                <div class="col-6 value" id="viewPhone"></div>
                            </div>
                            <div class="row">
                                <div class="col-6 text-end label">Hobbies:</div>
                                <div class="col-6 value" id="viewHobbies"></div>
                            </div>
                    	</div>
                	</div>
            	</div>
        	</div>
    	</div>
		
		<script src="../../assets/js/bootstrap.min.js"></script>
		<script src="../../assets/js/bootstrap.bundle.min.js"></script>
		<script src="../../assets/js/jquery.js"></script>
		<script src="../../assets/js/deleteScript.js"></script>
		<script src="../../assets/js/addScript.js"></script>
		
		
		
	</body>
</html>

