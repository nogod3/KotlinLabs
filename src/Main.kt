import kotlinx.cli.ArgParser
import kotlinx.cli.ArgType
import java.security.MessageDigest
import kotlin.system.exitProcess

private enum class AccessRight {
    READ,
    WRITE,
    EXECUTE
}

private data class User(
    val login: String,
    val salt: String,
    val passwordHash: String,
    val permissions: Map<String, Set<AccessRight>>
)

private val users = listOf(
    User(
        login = "alice",
        salt = "alice_salt_2026",
        passwordHash = "e54a67b17797e26a6452bc994d028da332275314819dcbbb9dcc9a97dcf7d461",
        permissions = mapOf(
            "A" to setOf(AccessRight.READ, AccessRight.WRITE),
            "TOOLS" to setOf(AccessRight.EXECUTE),
            "PRIVATE" to setOf(AccessRight.READ)
        )
    ),
    User(
        login = "bob",
        salt = "bob_salt_2026",
        passwordHash = "ce1fe84767eb205a0342467698dac7a17c5b2b94e09482c0773b4cb693a22990",
        permissions = mapOf(
            "A.B" to setOf(AccessRight.READ),
            "PUBLIC" to setOf(AccessRight.READ)
        )
    )
)

private val resources = mapOf(
    "A" to 100,
    "A.B" to 50,
    "A.B.C" to 20,
    "A.B.C.f_d" to 10,
    "TOOLS" to 5,
    "TOOLS.compiler" to 2,
    "PUBLIC" to 100,
    "PRIVATE" to 5
)

private val resourcePattern = Regex("^[A-Za-z0-9_]{1,20}(\\.[A-Za-z0-9_]{1,20})*$")

private fun hashPassword(password: String, salt: String): ByteArray {
    val digest = MessageDigest.getInstance("SHA-256")
    return digest.digest((salt + password).toByteArray(Charsets.UTF_8))
}

private fun hexToBytes(value: String): ByteArray {
    return value.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
}

private fun hasPermission(user: User, resource: String, right: AccessRight): Boolean {
    val inheritedRights = user.permissions
        .filterKeys { parent -> resource == parent || resource.startsWith("$parent.") }
        .maxByOrNull { it.key.length }
        ?.value

    return inheritedRights?.contains(right) == true
}

private fun printHelp() {
    println("Использование:")
    println("  java -jar app.jar --login LOGIN --password PASSWORD --action ACTION --resource PATH --volume NUMBER")
    println()
    println("Аргументы:")
    println("  --login      логин пользователя")
    println("  --password   пароль пользователя")
    println("  --action     действие: read, write или execute")
    println("  --resource   путь до ресурса, например A.B.C")
    println("  --volume     запрашиваемый объем ресурса")
    println("  -h, --help   показать эту справку")
}

private fun runApplication(args: Array<String>): Int {
    val parser = ArgParser("resource-access")
    val login by parser.option(ArgType.String, fullName = "login", description = "Логин пользователя")
    val password by parser.option(ArgType.String, fullName = "password", description = "Пароль пользователя")
    val action by parser.option(ArgType.String, fullName = "action", description = "Действие: read, write или execute")
    val resource by parser.option(ArgType.String, fullName = "resource", description = "Путь до ресурса, например A.B.C")
    val volume by parser.option(ArgType.String, fullName = "volume", description = "Запрашиваемый объем ресурса")

    if (args.contains("-h") || args.contains("--help")) {
        printHelp()
        return 1
    }

    try {
        parser.parse(args)
    } catch (_: Exception) {
        printHelp()
        return 1
    }

    if (login == null || password == null || action == null || resource == null || volume == null) {
        printHelp()
        return 1
    }

    val currentUser = users.find { it.login == login } ?: return 3

    val enteredHash = hashPassword(password!!, currentUser.salt)
    val savedHash = hexToBytes(currentUser.passwordHash)
    if (!MessageDigest.isEqual(enteredHash, savedHash)) {
        return 2
    }

    val requiredRight = when (action!!.lowercase()) {
        "read" -> AccessRight.READ
        "write" -> AccessRight.WRITE
        "execute" -> AccessRight.EXECUTE
        else -> return 4
    }

    val resourcePath = resource!!
    val requestedVolume = volume!!.toIntOrNull() ?: return 7
    if (!resourcePattern.matches(resourcePath) || requestedVolume < 0) {
        return 7
    }

    val maximumVolume = resources[resourcePath] ?: return 6
    if (!hasPermission(currentUser, resourcePath, requiredRight)) {
        return 5
    }

    if (requestedVolume > maximumVolume) {
        return 8
    }

    return 0
}

fun main(args: Array<String>) {
    exitProcess(runApplication(args))
}
