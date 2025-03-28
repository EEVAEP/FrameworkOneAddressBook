$(document).ready(function() {
   
    $("#confirmPassword").keyup(function() {
    	var password = $("#password").val();
        var confirmPassword = $(this).val();

        if (password !== confirmPassword) {
            $("#confirmPasswordError").text("Passwords do not match.");
        } else {
            $("#confirmPasswordError").text("");
        }
    });

    
    $("#myForm").submit(function(event) {
        var password = $("#password").val();
        var confirmPassword = $("#confirmPassword").val();

        if (password !== confirmPassword) {
            $("#confirmPasswordError").text("Passwords do not match.");
            event.preventDefault(); 
        }
    });
});
