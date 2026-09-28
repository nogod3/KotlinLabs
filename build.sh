#!/usr/bin/env bash

set -e

CLI_JAR="lib/kotlinx-cli-jvm-0.3.6.jar"

if [ -n "${KOTLIN_HOME:-}" ] && [ -x "$KOTLIN_HOME/bin/kotlinc" ]; then
    KOTLINC="$KOTLIN_HOME/bin/kotlinc"
elif command -v kotlinc >/dev/null 2>&1; then
    KOTLINC="$(command -v kotlinc)"
else
    echo "Не найден kotlinc. Установите Kotlin compiler или задайте KOTLIN_HOME."
    exit 1
fi

if ! command -v jar >/dev/null 2>&1; then
    echo "Не найдена команда jar. Установите JDK и добавьте его bin в PATH."
    exit 1
fi

if [ ! -f "$CLI_JAR" ]; then
    echo "Не найдена библиотека $CLI_JAR"
    exit 1
fi

rm -rf .build
mkdir -p .build/fatjar

"$KOTLINC" src/Main.kt -cp "$CLI_JAR" -include-runtime -d .build/app-base.jar

(
    cd .build/fatjar
    jar xf ../app-base.jar
    jar xf ../../"$CLI_JAR"
    rm -f META-INF/*.SF META-INF/*.RSA META-INF/*.DSA
    jar cfe ../../app.jar MainKt .
)

echo "Сборка завершена: app.jar"
