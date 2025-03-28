<cfscript>
	if (structKeyExists(url, "logOut")) {
		structDelete(session, "username");
		structDelete(session, "userid");
	}

	try {
		if (structKeyExists(session, "username")) {
			location(url="dashboard.cfm", addtoken="false");
		}
		if (structKeyExists(form, "submit")) {
			user = application.UserController.validateUserLogin(username=form.username, password=form.password);
			if (structKeyExists(user, "username") && user.username == form.username) {
				session.username = user.username;
				session.userid = user.userid;
				location(url="./user/dashboard.cfm", addtoken="false");
			} else {
				errorMessage = "Invalid Username or Password";
			}
		}
		
	} catch (any e) {
		writeDump(var=e);
	}
</cfscript>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Login Page</title>
		<link rel="stylesheet" href="../assets/css/styleLogin.css">
	</head>
	<body>
		<nav class="navbar">
			<div class="navbar-left">
				<img src="../assets/img/addressbook.png" alt="Address Book Icon" class="nav-icon">
				<span>ADDRESS BOOK</span>
			</div>
			<div class="navbar-right">
				<a href="./signup.cfm" class="nav-link">Sign Up</a>
			</div>
		</nav>
		<div class="container">
			<div class="login-box">
				<div class="icon-side">
					<img src="../assets/img/addressbook.png" alt="Address Book Icon" class="icon">
				</div>
				<div class="form-side">
					<h2>LOGIN</h2>
					<form method="post" action="login.cfm">
						<div class="input-box">
							<label for="username">Username</label>
							<input type="text" id="username" name="username">
						</div>
						<div class="input-box">
							<label for="password">Password</label>
							<input type="password" id="password" name="password">
						</div>
						<button type="submit" name="submit" class="login-btn">LOGIN</button>
						<cfif structKeyExists(variables, "errorMessage")>
							<span class="error">
								<cfoutput>#errorMessage#</cfoutput>
							</span>
						</cfif>
					</form>
				</div>
			</div>
		</div>
	</body>
</html>
