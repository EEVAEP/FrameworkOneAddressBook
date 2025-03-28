component {
    private function hashPassword(required string pass, required string salt) {
        local.saltedPass = arguments.pass & arguments.salt;
        local.hashedPass = hash(local.saltedPass, "SHA-256", "UTF-8");
        return local.hashedPass;
    }

   	public struct function validateUserLogin(required string username, required string password) {
        var local = {};
        local.qryLogin = queryExecute(
            "SELECT 
				id AS userid,
				username,
				password,
				salt
			FROM 
				register
			WHERE 
				username = :username",
            { username: { value: arguments.username, cfsqltype: "cf_sql_varchar" } }
        );

        if (local.qryLogin.recordCount EQ 1) {
            local.salt = local.qryLogin.salt;
            local.hashedPassword = hashPassword(arguments.password, local.salt);
            local.result = {};

            if (local.hashedPassword EQ local.qryLogin.password) {
                local.result["userid"] = local.qryLogin.userid;
                local.result["username"] = local.qryLogin.username;
            }
        }
		return local.result;
    }
}