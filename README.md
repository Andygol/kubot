# kubot

Практичне завдання зі створення застосунків з чистого аркуша для засвоєння практик DevOps.

- `go mod init github.com/Andygol/kubot` – ініціалізація проєкту
- `go install github.com/spf13/cobra-cli@latest` – встановлення Cobra CLI, бібліотеки з інструментами для швидкого створення застосунків
- `cobra-cli init` – ініціалізація бібліотеки
- `cobra-cli add version` – додавання команди `version`
- `go run main.go help` – запуск з параметром `help`

```
A longer description that spans multiple lines and likely contains
examples and usage of using your application. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.

Usage:
  kubot [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  help        Help about any command
  version     A brief description of your command

Flags:
  -h, --help     help for kubot
  -t, --toggle   Help message for toggle

Use "kubot [command] --help" for more information about a command.
```

- `go run main.go version` – запуск з параметром `version`

```
version called
```

- `cobra-cli add kubot` – додавання параметра `kubot`
- `go build -ldflags "-X="github.com/Andygol/kubot/cmd.appVersion=v1.0.0` – збірка із зазначенням номера версії
- `./kubot version` – перевірка версії

```
v1.0.0
```

- `gofmt -s -w ./` – форматування коду
- додавання аліасу `start` до команди `kubot`

```sh
./kubot start
kubot v1.0.1 started2023/11/09 11:59:39 Please check TELE_TOKEN env variable. telegram: Not Found (404)
```

- `read -s TELE_TOKEN` – додавання токена для доступу до API Telegram, після натискання вводу вставити код токена з буфера обміну <kbd>cmd</kbd>+<kbd>V</kbd>

- `echo $TELE_TOKEN` – перевірка значення системної змінної TELE_TOKEN
- `export TELE_TOKEN` – використання системної змінної

- запуск бота

```sh
./kubot start
kubot v1.0.1 started2023/11/09 12:36:17 /start
2023/11/09 12:37:01 hello/start hello
```

- додавання обробника команди `/start hello` та збирання оновленої версії бота `go build -ldflags "-X="github.com/Andygol/kubot/cmd.appVersion=v1.0.2`

```sh
./kubot start
kubot v1.0.2 started2023/11/09 12:41:53 hello/start hello
```

## Посилання на бота

[t.me/kubot621_bot](t.me/kubot621_bot)
