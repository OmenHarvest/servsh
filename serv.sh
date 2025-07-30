#!/bin/bash

JAR_PATH="[path here]"

# Проверка, что файл .jar существует
if [ ! -f "$JAR_PATH" ]; then
  echo "❌ Ошибка: Файл $JAR_PATH не найден!"
  exit 1
fi

#config + jvm settings
JAVA_OPTS="-Xms256m -Xmx512m"
APP_NAME="utilsdev"
LOG_FILE="serv.log"

start() {
  if is_running; then
    echo "⚠️  $APP_NAME уже запущен (PID: $(get_pid))"
    return 1
  fi

  echo "🚀 Запуск $APP_NAME..."
  nohup java $JAVA_OPTS -jar "$JAR_PATH" >> "$LOG_FILE" 2>&1 &
  echo "✅ $APP_NAME запущен (PID: $!)"
}


stop() {
  if ! is_running; then
    echo "⚠️  $APP_NAME не запущен"
    return 1
  fi

  echo "🛑 Остановка $APP_NAME (PID: $(get_pid))..."
  kill -9 $(get_pid)
  sleep 3
  if is_running; then
    echo "❌ Не удалось остановить $APP_NAME!"
    return 1
  else
    echo "✅ $APP_NAME остановлен"
  fi
}

restart() {
  stop
  sleep 2
  start
}

status() {
  if is_running; then
    echo "🟢 $APP_NAME работает (PID: $(get_pid))"
  else
    echo "🔴 $APP_NAME не запущен"
  fi
}

is_running() {
  [ -n "$(get_pid)" ]
}

get_pid() {
  pgrep -f "java.*$JAR_PATH"
}

# Обработка аргументов
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  *)
    echo "Использование: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
