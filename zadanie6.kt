fun main(args: Array<String>) {
    val words = if (args.isNotEmpty())
    {
        args.toList()
    }   else {
        val input =readLine() ?: ""
        input.split(Regex("\\s+")) .filter {it.isNotEmpty() }
    }
    val map = mutableMapOf<String, Int>()
    for (word in words) {
        map[word] =
            map.getOrDefault(word, 0) + 1
    }
    val sortedEntries = map.toList() .sortedWith(
        compareByDescending<Pair<String, Int>>
        { it.second } .thenBy {it.first}
    )
    for ((word, count) in sortedEntries) {
        println("$word $count")
    }
}
