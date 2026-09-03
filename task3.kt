fun main (args: Array<String>) {
    val unique =
        args.distinct() .sorted()
    for (word in unique) {
        println(word)
    }
}