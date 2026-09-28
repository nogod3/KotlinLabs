#!/usr/bin/env bash

set +e

if [ ! -f app.jar ]; then
    ./build.sh || exit 1
fi

passed=0
total=10

check_case() {
    name="$1"
    expected="$2"
    shift 2

    ./run.sh "$@" >/dev/null 2>&1
    actual=$?

    if [ "$actual" -eq "$expected" ]; then
        echo "OK   $name (код $actual)"
        passed=$((passed + 1))
    else
        echo "FAIL $name (ожидался $expected, получен $actual)"
    fi
}

check_case "успешный доступ" 0 --login alice --password qwerty --action read --resource A.B.C --volume 10
check_case "справка" 1 --help
check_case "неверный пароль" 2 --login alice --password wrong --action read --resource A --volume 1
check_case "неверный логин" 3 --login unknown --password qwerty --action read --resource A --volume 1
check_case "неизвестное действие" 4 --login alice --password qwerty --action delete --resource A --volume 1
check_case "нет доступа" 5 --login alice --password qwerty --action write --resource PUBLIC --volume 1
check_case "несуществующий ресурс" 6 --login alice --password qwerty --action read --resource A.UNKNOWN --volume 1
check_case "неверный формат ресурса" 7 --login alice --password qwerty --action read --resource A..B --volume 1
check_case "неверный объем" 7 --login alice --password qwerty --action read --resource A --volume text
check_case "объем превышен" 8 --login alice --password qwerty --action read --resource A.B.C --volume 21

echo "$passed/$total"

if [ "$passed" -eq "$total" ]; then
    exit 0
else
    exit 1
fi
