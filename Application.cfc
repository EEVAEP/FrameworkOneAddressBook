component output="false" {
    this.name = "AddressBookAuthentication";
    this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 0, 30, 0);
    this.setClientCookies = true;
    this.datasource = "addressbook";

    this.framework = {
        action = "action",
        defaultSection = "views",
        defaultItem = "login",
        password = "secret",
        reloadApplicationOnEveryRequest = 1
    };

    public boolean function onApplicationStart() {
        application.fw1 = createObject("component", "framework.one").init();
        application.userController = createObject("component", "controllers.UserController");
        application.userService = createObject("component", "model.UserService");
        application.encryptionKey = generateSecretKey("AES");
        application.titleQuery = application.userService.getTitleName();
        application.genderQuery = application.userService.getGenderName();
        application.hobbyQuery = application.userService.getHobbyName();
        return true;
    }

    public void function onRequestStart(required string requestname) {
        if (structKeyExists(url, "reload") && url.reload == 1) {
            onApplicationStart();
        }

        local.pages = ["login.cfm"];
        if (!structKeyExists(session, "username") && !arrayFindNoCase(local.pages, listLast(CGI.SCRIPT_NAME, "/"))) {
            location(url="login.cfm", addToken="no");
        }
    }
}