![](https://img.shields.io/badge/Swift-5.0-informational?style=flat)
![](https://img.shields.io/badge/iOS-16.0-informational?style=flat)
![](https://img.shields.io/badge/architecture-MVVM-informational?style=flat)
![](https://img.shields.io/badge/SwiftUI-informational?style=flat)
![](https://img.shields.io/badge/Realm-informational?style=flat)
![](https://img.shields.io/badge/SPM-informational?style=flat)


# Startribe Test App

### Тестовое приложение для компании Startribe

Имеет три экрана:
- Лента новостей
- Детальный обзор новости
- Настройки

### Лента новостей
 Получает данные из двух источников - ведомости и РБК
 Имеет два режима отображения:
  - **Обычный**: картинка + заголовок
  - **Расширенный**: картинка + заголовок + краткое описание новости
    
Режим меняется при нажатии на кнопку в NavigationBar'e
Есть возможность обновить данные используя механизм ***Pull-to-refresh***
Есть индикация просмотра новости - заголовок и описание становятся серого цвета

![](https://github.com/AndreyK-16/Startribe-Test-App/blob/main/img/newslist.png)


### Детальный обзор новости
Дочерний экран "Ленты новостей"

![](https://github.com/AndreyK-16/Startribe-Test-App/blob/main/img/newsDetail.png)

### Настройки
На экране настроек представлен функционал:
- Выбор частоты обновления (5, 10, 15, 30, 60, 120 минут)
- Моментальное обновление
- Включение/выключение источников новостей
- Просмотр размера кэша
- Очистка кэша изображений

![](https://github.com/AndreyK-16/Startribe-Test-App/blob/main/img/settings.png)
