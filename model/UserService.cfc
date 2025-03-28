component{
	
    public string function decryptId(required string encryptedId) {
        var local = {};
        local.decryptedId = decrypt(arguments.encryptedId, application.encryptionKey, "AES", "Hex");
        return local.decryptedId;
    }

    public query function getTitleName() {
        var local = {};
        local.titleName = queryExecute(
            "SELECT idtitle, titlename FROM title"
        );
        return local.titleName;
    }

    public query function getGenderName() {
        var local = {};
        local.genderTitle = queryExecute(
            "SELECT idgender, gendername FROM gender"
        );
        return local.genderTitle;
    }

    public query function getHobbyName() {
        var local = {};
        local.insertHobby = queryExecute(
            "SELECT idhobby, hobby_name FROM hobbies_sample"
        );
        return local.insertHobby;
    }

	public query function getTotalUserDetails() {
        var local = {};

        local.qryPages = queryExecute(
            "SELECT 
                c.idcontact,
                c.titleid,
                c.genderid,
                CONCAT(firstname, ' ', lastname) AS Fullname,
                c.firstname,
                c.lastname,
                CONCAT(t.titlename, ' ', c.firstname, ' ', c.lastname) AS titleFullname, 
                c.email, 
                c.phone,
                c.photo,
                c.dob,
                c.address,
                c.pincode,
                c.street,
                t.titlename,
                g.gendername,
                c.iduser,
                c.is_public,
                GROUP_CONCAT(h.idhobby) AS hobby_ids,
                GROUP_CONCAT(h.hobby_name) AS hobby_names
            FROM contact c
            INNER JOIN title t ON c.titleid = t.idtitle
            INNER JOIN gender g ON c.genderid = g.idgender
            INNER JOIN user_hobbies uh ON c.idcontact = uh.contact_id
            INNER JOIN hobbies_sample h ON uh.hobby_id = h.idhobby
            WHERE (iduser = :userid OR c.is_public = 1)
            GROUP BY c.idcontact",
            { userid: { value: session.userid, cfsqltype: "cf_sql_integer" } }
        );

        return local.qryPages;
    }

	public any function validateAddEditContactDetails(
        numeric title=false,
        string titleName=false,
        string firstName,
        string lastName,
        numeric gender=false,
        string genderName=false,
        string dob,
        string photo=false,
        string address,
        string street,
        string pincode,
        string email,
        string phone,
        string hobbies=false,
        string hobbiesName=false,
        numeric is_public,
        string contactId=false,
        numeric is_excel=false
    ) returnformat="JSON" {
		// writeDump(var=arguments, abort=true);
        var local = {};
        local.result = { "errors": [], "remarks": "" };

        if (structKeyExists(arguments, "title") AND NOT arguments.title EQ 'false') {
            local.validTitles = [];
            for (var row in application.titleQuery) {
                arrayAppend(local.validTitles, row.idtitle);
            }
            if (!arrayContains(local.validTitles, arguments.title)) {
                arrayAppend(local.result.errors, "*The title must be one of the following: " & arrayToList(local.validTitles, ", "));
            }
        }

        if (structKeyExists(arguments, "titleName") AND NOT arguments.titleName EQ 'false') {
            local.validTitleNames = [];
            for (var row in application.titleQuery) {
                arrayAppend(local.validTitleNames, row.titlename);
            }
            if (!arrayContains(local.validTitleNames, arguments.titleName)) {
                arrayAppend(local.result.errors, "*The title name must be one of the following: " & arrayToList(local.validTitleNames, ", "));
            } else {
                local.getTitleId = queryExecute(
                    "SELECT idtitle FROM application.titleQuery WHERE titlename = :titleName",
                    { titleName: { value: arguments.titleName, cfsqltype: "cf_sql_varchar" } },
                    { dbtype: "query" }
                );
                if (local.getTitleId.recordCount EQ 1) {
                    arguments["title"] = local.getTitleId.idtitle;
                }
            }
        }

        if (trim(arguments.firstName) EQ "") {
            arrayAppend(local.result.errors, "*First Name is required.");
        } else if (!reFind("^[A-Za-z]+$", trim(arguments.firstName))) {
            arrayAppend(local.result.errors, "*First Name cannot contain numbers or special characters.");
        }

        if (trim(arguments.lastName) EQ "") {
            arrayAppend(local.result.errors, "*Last Name is required.");
        } else if (!reFind("^[A-Za-z]+(\s[A-Za-z]+)*$", trim(arguments.lastName))) {
            arrayAppend(local.result.errors, "*Last Name cannot contain numbers or special characters.");
        }

        if (structKeyExists(arguments, "gender")) {
            local.validGender = [];
            for (var row in application.genderQuery) {
                arrayAppend(local.validGender, row.idgender);
            }
            if (!arrayContains(local.validGender, arguments.gender)) {
                arrayAppend(local.result.errors, "*Enter a valid gender");
            }
        }

        if (!isDate(arguments.dob)) {
            arrayAppend(local.result.errors, "*Date of Birth must be a valid date.");
        }

        local.uploadPath = ExpandPath('../../assets/uploads/');
		
        
        if (structKeyExists(form, "photo") AND len(form.photo) GT 0) {
            local.fileUploadResult = fileUpload(destination=local.uploadPath, fileField="photo",mimeType="image/jpeg,image/png,image/jfif", onConflict="makeUnique");
            local.originalFileName = local.fileUploadResult.serverFile;

            local.allowedFormats = "jpg,jpeg,png,jfif";
            local.imageExtension = listLast(local.originalFileName, ".");

            if (!listFindNoCase(local.allowedFormats, local.imageExtension)) {
                arrayAppend(local.result.errors, "*Invalid image format. Only JPG, JPEG, JFIF and PNG are allowed");
            } else {
                local.uploadPath = ExpandPath('../../assets/Temp/');
                local.fileUploadResult = fileUpload(destination=local.uploadPath, fileField="photo",mimeType="image/jpeg,image/png,image/jfif", onConflict="makeUnique");
                local.photopath = "../../assets/Temp/" & local.fileUploadResult.serverFile;
                arguments["photo"] = local.photopath;
            }
        } else if (structKeyExists(arguments, "contactId") AND len(arguments.contactId) GT 0 AND arguments.photo EQ "") {
            local.decryptedId = decryptId(arguments.contactId);
            local.getPhotoPath = queryExecute(
                "SELECT photo FROM contact WHERE idcontact = :decryptedId",
                { decryptedId: { value: local.decryptedId, cfsqltype: "cf_sql_integer" } }
            );
            arguments["photo"] = local.getPhotoPath.photo;
        } else if (structKeyExists(arguments, "is_excel") AND arguments.is_excel EQ 1 AND (!structKeyExists(arguments, "contactId"))) {
            local.photopath = "./Temp/user.png";
            arguments["photo"] = local.photopath;
        } else {
            if (!structKeyExists(arguments, "is_excel") OR arguments.is_excel NEQ 1) {
                arrayAppend(local.result.errors, "*Image is required");
            }
        }

        if (trim(arguments.address) EQ "") {
            arrayAppend(local.result.errors, "*Address is required.");
        }

        if (trim(arguments.street) EQ "") {
            arrayAppend(local.result.errors, "*Street is required.");
        }

        if (trim(arguments.pincode) EQ "" OR (!isNumeric(arguments.pincode))) {
            arrayAppend(local.result.errors, "*Pincode must be numeric");
        } else if (len(arguments.pincode) GT 8) {
            arrayAppend(local.result.errors, "*Pincode length must be less than 9");
        }

        local.getContactEmail = queryExecute(
            "SELECT idcontact FROM contact WHERE email = :email",
            { email: { value: arguments.email, cfsqltype: "cf_sql_varchar" } }
        );

        if (local.getContactEmail.recordCount GT 0 AND (!structKeyExists(arguments, "contactId") OR len(trim(arguments.contactId)) EQ 0)) {
            if (!structKeyExists(arguments, "is_excel")) {
                arrayAppend(local.result.errors, "*Email already exists");
            } else {
                local.result.remarks = "UPDATED";
                arguments["contactId"] = local.getContactEmail.idcontact;
            }
        } else if (len(trim(arguments.email)) EQ 0) {
            arrayAppend(local.result.errors, "*Email is required");
        } else if (!reFindNoCase("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", arguments.email)) {
            arrayAppend(local.result.errors, "*Enter a valid email");
        } else {
            local.result.remarks = "ADDED";
        }

        if (trim(arguments.phone) EQ "" OR !reFind("^\d{10}$", arguments.phone)) {
            arrayAppend(local.result.errors, "*Phone number must contain exactly 10 digits.");
        }

        if (structKeyExists(arguments, "hobbies")) {
            if (len(arguments.hobbies) EQ 0) {
                arrayAppend(local.result.errors, "*Hobby is required");
            } else {
                local.validHobbies = [];
                for (var row in application.hobbyQuery) {
                    arrayAppend(local.validHobbies, row.idhobby);
                }
                local.selectedHobbiesArray = listToArray(arguments.hobbies, ",");
                for (var hobbyID in local.selectedHobbiesArray) {
                    if (!arrayContains(local.validHobbies, hobbyID)) {
                        arrayAppend(local.result.errors, "*Invalid hobby selected: " & hobbyID);
                    }
                }
            }
        }

        local.isValidPublic = ["0", "1"];
        if (!arrayContains(local.isValidPublic, arguments.is_public)) {
            arrayAppend(local.result.errors, "*Invalid value for Public");
        }

        if (arrayLen(local.result.errors) EQ 0) {
            local.addUser = createOrUpdateContact(argumentCollection=arguments);
            return local.result;
        } else {
            return local.result;
        }
    }

	
    public void function createOrUpdateContact(required string title, required string firstName, required string lastName, required string gender, required string dob, string photo, required string address, required string street, required string pincode, required string email, required string phone, string hobbies, required numeric is_public, string contactId = "", numeric is_excel) {
        var local = {};

        if (StructKeyExists(arguments, "contactId") AND arguments.contactId NEQ "") {
            local.decryptedId = decryptId(arguments.contactId);
            queryExecute(
                "UPDATE contact SET
                    titleid = :title,
                    firstname = :firstName,
                    lastname = :lastName,
                    genderid = :gender,
                    dob = :dob,
                    photo = :photo,
                    address = :address,
                    street = :street,
                    pincode = :pincode,
                    email = :email,
                    phone = :phone,
                    iduser = :userId,
                    is_public = :isPublic
                WHERE
                    idcontact = :contactId
                AND
                    iduser = :userId",
                {
                    title: {value: arguments.title, cfsqltype: "cf_sql_integer"},
                    firstName: {value: arguments.firstName, cfsqltype: "cf_sql_varchar"},
                    lastName: {value: arguments.lastName, cfsqltype: "cf_sql_varchar"},
                    gender: {value: arguments.gender, cfsqltype: "cf_sql_integer"},
                    dob: {value: arguments.dob, cfsqltype: "cf_sql_date"},
                    photo: {value: arguments.photo, cfsqltype: "cf_sql_varchar"},
                    address: {value: arguments.address, cfsqltype: "cf_sql_varchar"},
                    street: {value: arguments.street, cfsqltype: "cf_sql_varchar"},
                    pincode: {value: arguments.pincode, cfsqltype: "cf_sql_integer"},
                    email: {value: arguments.email, cfsqltype: "cf_sql_varchar"},
                    phone: {value: arguments.phone, cfsqltype: "cf_sql_varchar"},
                    userId: {value: session.userid, cfsqltype: "cf_sql_integer"},
                    isPublic: {value: arguments.is_public, cfsqltype: "cf_sql_integer"},
                    contactId: {value: local.decryptedId, cfsqltype: "cf_sql_integer"}
                }
            );

            local.existingHobbies = queryExecute(
                "SELECT hobby_id FROM user_hobbies WHERE contact_id = :contactId",
                { contactId: {value: local.decryptedId, cfsqltype: "cf_sql_integer"} }
            );

            local.existingHobbiesArray = ListToArray(ValueList(local.existingHobbies.hobby_id, ","), ",");
            local.selectedHobbiesArray = ListToArray(arguments.hobbies, ",");

            local.hobbiesToAdd = [];
            for (local.selectedHobby in local.selectedHobbiesArray) {
                if (!ArrayContains(local.existingHobbiesArray, local.selectedHobby)) {
                    ArrayAppend(local.hobbiesToAdd, local.selectedHobby);
                }
            }

            queryExecute(
                "DELETE FROM user_hobbies WHERE contact_id = :contactId AND hobby_id NOT IN (:hobbies)",
                {
                    contactId: {value: local.decryptedId, cfsqltype: "cf_sql_integer"},
                    hobbies: {value: arguments.hobbies, cfsqltype: "cf_sql_integer", list: true}
                }
            );

            if (ArrayLen(local.hobbiesToAdd) > 0) {
                for (local.hobbyIdToAdd in local.hobbiesToAdd) {
                    queryExecute(
                        "INSERT INTO user_hobbies (contact_id, hobby_id) VALUES (:contactId, :hobbyId)",
                        {
                            contactId: {value: local.decryptedId, cfsqltype: "cf_sql_integer"},
                            hobbyId: {value: local.hobbyIdToAdd, cfsqltype: "cf_sql_integer"}
                        }
                    );
                }
            }
        } else {
            local.r = queryExecute(
                "INSERT INTO contact (titleid, firstname, lastname, genderid, dob, photo, address, street, pincode, email, phone, iduser, is_public)
                VALUES (:title, :firstName, :lastName, :gender, :dob, :photo, :address, :street, :pincode, :email, :phone, :userId, :isPublic)",
                {
                    title: {value: arguments.title, cfsqltype: "cf_sql_integer"},
                    firstName: {value: arguments.firstName, cfsqltype: "cf_sql_varchar"},
                    lastName: {value: arguments.lastName, cfsqltype: "cf_sql_varchar"},
                    gender: {value: arguments.gender, cfsqltype: "cf_sql_integer"},
                    dob: {value: arguments.dob, cfsqltype: "cf_sql_date"},
                    photo: {value: arguments.photo, cfsqltype: "cf_sql_varchar"},
                    address: {value: arguments.address, cfsqltype: "cf_sql_varchar"},
                    street: {value: arguments.street, cfsqltype: "cf_sql_varchar"},
                    pincode: {value: arguments.pincode, cfsqltype: "cf_sql_integer"},
                    email: {value: arguments.email, cfsqltype: "cf_sql_varchar"},
                    phone: {value: arguments.phone, cfsqltype: "cf_sql_varchar"},
                    userId: {value: session.userid, cfsqltype: "cf_sql_integer"},
                    isPublic: {value: arguments.is_public, cfsqltype: "cf_sql_integer"}
                },
                { result: "local.r", returnGeneratedKeys: true }
            );
			
			local.lastIdQuery = queryExecute("SELECT LAST_INSERT_ID() AS id", {}, {});
			local.r.generatedKey = local.lastIdQuery.id;

            local.selectedHobbiesArray = ListToArray(arguments.hobbies, ",");
            for (local.hobbyID in local.selectedHobbiesArray) {
                queryExecute(
                    "INSERT INTO user_hobbies (contact_id, hobby_id) VALUES (:contactId, :hobbyId)",
                    {
                        contactId: {value: local.r.generatedKey, cfsqltype: "cf_sql_integer"},
                        hobbyId: {value: local.hobbyID, cfsqltype: "cf_sql_integer"}
                    }
                );
            }
        }
    }

	remote any function getDataById(required string contactId) returnformat="JSON" {
        var local = {};
        local.decryptedId = decryptId(arguments.contactId);

        try {
            local.getCont = queryExecute(
                "SELECT 
                    c.idcontact,
                    c.titleid,
                    c.firstname,
                    c.lastname,
                    c.genderid,
                    c.dob,
                    c.photo,
                    c.address,
                    c.street,
                    c.pincode,
                    c.email,  
                    c.phone,
                    t.titlename,
                    g.gendername,
                    c.is_public,
                    GROUP_CONCAT(h.idhobby) AS hobby_ids,   
                    GROUP_CONCAT(h.hobby_name) AS hobby_names
                FROM contact c
                INNER JOIN title t ON c.titleid = t.idtitle
                INNER JOIN gender g ON c.genderid = g.idgender
                INNER JOIN user_hobbies uh ON c.idcontact = uh.contact_id
                INNER JOIN hobbies_sample h ON uh.hobby_id = h.idhobby
                WHERE c.idcontact = :decryptedId",
                { decryptedId: { value: local.decryptedId, cfsqltype: "cf_sql_integer" } }
            );

            local.singleData = {};
            if (local.getCont.recordCount GT 0) {
                local.singleData = {
                    "idcontact": local.getCont.idcontact,
                    "titleid": local.getCont.titleid,
                    "titlename": local.getCont.titlename,
                    "firstname": local.getCont.firstname,
                    "lastname": local.getCont.lastname,
                    "genderid": local.getCont.genderid,
                    "gendername": local.getCont.gendername,
                    "dob": local.getCont.dob,
                    "photo": local.getCont.photo,
                    "address": local.getCont.address,
                    "street": local.getCont.street,
                    "pincode": local.getCont.pincode,
                    "email": local.getCont.email,
                    "phone": local.getCont.phone,
                    "is_public": local.getCont.is_public,
                    "hobby_ids": local.getCont.hobby_ids,
                    "hobby_names": local.getCont.hobby_names
                };
            }

            return local.singleData;
        } catch (any e) {
            writedump(e);
        }
    }

    remote struct function deleteContact(required string contactId) returnformat="JSON" {
        var local = {};
        local.decryptedId = decryptId(arguments.contactId);

        try {
            queryExecute(
                "DELETE FROM contact 
                WHERE idcontact = :decryptedId 
                AND iduser = :userid",
                {
                    decryptedId: { value: local.decryptedId, cfsqltype: "cf_sql_integer" },
                    userid: { value: session.userid, cfsqltype: "cf_sql_integer" }
                }
            );

            local.response = { status = "success", message = "Contact deleted successfully." };
            return local.response;
        } catch (any e) {
            local.response = { status = "error", message = "An error occurred while deleting the contact." };
            return local.response;
        }
    }


}

