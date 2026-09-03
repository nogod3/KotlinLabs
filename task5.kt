fun main(args: Array<String>) {
    val map = mutableMapOf<String,Int>()
    for (word in args) {
        map[word] =
            map.getOrDefault(word, 0) + 1
    }
    val sortedEntries =
        map.toList(). sortedWith(
            compareByDescending<Pair<String, Int>>
            {it.second } .thenBy {it.first}
        )
    for ((word, count) in
    sortedEntries) {
        println("$word $count")
    }
}