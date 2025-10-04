#!/bin/bash
# Завершаем работающие экземпляры Polybar
killall -q polybar
# Ждем полного завершения процессов
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
# Запускаем Polybar, используя ваш config.ini
polybar example &
echo "Polybar запущен...":
