# **Multiddos - скрипт объединяющий в себе несколько утилит для ddos**

![multiddos](https://user-images.githubusercontent.com/53382906/161972523-a1197762-a166-45f2-9b68-6e13cc940d99.gif)

## **Особености**:
* Объединяет в себе несколько утилит для ддоса, и для мониторинга (gotop, vnstat)
* Полностью автоматизирован. Автоматическое обновление программ, автоматическая настройка, автоматическая смена целей.
* Запуск одной простой командой.
* При закрытии терминала или разрыве ssh сессии программы не вылетают, а продолжают работать в фоне. В любой момент multiddos можно снова вывести на экран.

## **На данный момент скрипт поддерживает:**
* [Multiddos](https://github.com/KarboDuck/multiddos), ранее известный как auto_mhddos (обвертка для mhddos_proxy) от Украинского Жнеца ([канал](https://t.me/ukrainian_reaper_ddos), [чат](https://t.me/+azRzzKp-STpkMjNi))
* [db1000n ](https://github.com/Arriven/db1000n) от IT ARMY of Ukraine ([канал](https://t.me/itarmyofukraine2022), чат)
* [UA Cyber SHIELD](https://github.com/opengs/uashield) ([канал](https://t.me/uashield), чат) 

### **Пояснение к выбору конкретных утилит**
<details>
<summary>развернуть</summary>
 
Мы хотели собрать утилиты, которые:
* Можно полностью автоматизировать
* Имеют хорошую эффективность и поддерживаются разработчиками
* Умеют работать через прокси

Полностью данным требованиям соответствует только mhddos_proxy. DB1000N не умеет работать через прокси. Поэтому в bash-скрипте он запускается через tor. В docker-версии мы отключили DB1000N, так как работа tor там под вопросом. Это сделано для того, чтобы исключить случаи когда пользователь случайно запускает db1000n и "палит" свой IP. А это возможно когда он запускает docker-версию multiddos и у него не включены VPN.
 
</details>

---
# **Docker-версия multiddos. Рекомендуется.** (Windows, Mac, Linux)

## **Запуск**

1. Скачать и установить [Docker](https://docs.docker.com/get-docker/)
 * Команда для простой установки в Linux <details> sudo apt install apt-transport-https ca-certificates curl software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && sudo apt update && sudo apt install docker-ce -y
 * Альтернативная команда для простой установки в Linux <details> sudo apt update -y && sudo apt install -y docker-ce docker-ce-cli containerd.io
2. Запустить docker-версию multiddos:
```
docker run -it --rm --log-driver none --name multidd --pull always karboduck/multidd
```
* Альтернативный запуск для слабых систем. Будет использоваться только 1 ядро на 90% (использовать если процессор забивается на 100% и система тормозит) <details> docker run --cpus 0.9 -it --rm --log-driver none --name multidd --pull always karboduck/multidd

## **Остановка**
1. Нажать в окне несколько раз подряд `Ctrl + C`
2. В другом терминале запустить команду `docker stop multidd`
3. Перезагрузить операционную систему

## **Подключиться обратно, если скрипт работает в фоне**
```
docker attach multidd
```

---
# **Bash-версия multiddos** (Linux, WSL2)

## **Запуск**

```
curl -L tiny.one/multiddos | bash && tmux a
```

## **Запуск в фоне**
<details>
  <summary>развернуть</summary>
  
То же самое что и обычный запуск, но программы не будут выводиться из фона. Соответственно просто удаляем вызов Tmux в конце команды.

```
curl -L tiny.one/multiddos | bash
```
Чтобы обратно подключиться к сессии tmux (вывести программы на экран) прочитайте раздел **Управление Tmux**.
 
</details>

## **Остановка**:
1. Нажать в окне несколько раз подряд `Ctrl + C`
2. В другом терминале запустить команду `pkill tmux; pkill node; pkill shield; pkill -f start.py; pkill -f runner.py`
3. Перезагрузить операционную систему

## **Подключиться обратно, если скрипт работает в фоне**
```
tmux a
```
---
# **Управление Tmux**
<details>
  <summary>развернуть</summary>
* **Свернуть Tmux**. Программы продолжат работать в фоне, и к сессии можно будет позже снова подключиться. `Нажмите Ctrl+b` отпустите `Нажмите d`
* **Закрыть сессию Tmux**. Сначала выйдите из Tmux: `Нажмите Ctrl+b` отпустите `Нажмите d`. Выполните в терминале команду `tmux kill-session -t multiddos`
* **Переподключиться к сессии Tmux**. Если у вас всего одна сессия Tmux, то используйте: `tmux a` (tmux attach). Если у вас несколько сессий, подключайтесь по имени: `tmux attach-session -t multiddos`
</details>

---
# **Выбор конфигурации**

<details>
  <summary>развернуть</summary>
  
Multiddos запускается по умолчанию с gotop, multiddos и db1000n. Это стандартная конфигурация. Из этой конфигурации можно убрать gotop или db1000n. Или добавить в нее утилиты: uashield, vnstat, matrix.

Для того, чтобы убрать утилиту используется ключ со знаком "-":

`-g` убрать gotop

`-d` убрать db1000n

Для того, чтобы добавить утилиту используется ключ со знаком "+":

`+u` добавить uashield

`+v` добавить vnstat -l (мониторинг трафика)

`+m` добавить matrix (эффект матрицы)

Пример команды (убрать db1000n и добавить matrix):

```
curl -LO tiny.one/multiddos && bash multiddos -d +m && tmux a
```

Для изменения кол-ва потоков используйте `-t`

```
curl -LO tiny.one/multiddos && bash multiddos -t 1000 && tmux a
```

</details>
---

# **Решение проблем**
<details>
  <summary>развернуть</summary>
 
1. Основная проблема - перебои в работе сетевого адаптера. Особенно часто проявляется при запуске скрипта на виртуальной машине. Ддос пакеты влияют не только на удаленные сервера, но и на локальное железо.

Внешние проявления могут самыми разнообразными, нелогичными и на первый взгляд не связанными с сетью. Но, если скрипт не запускается, просто перезапустите систему и попробуйте снова. Едва ли не в 80% случаев это решает проблемы.
 
</details>