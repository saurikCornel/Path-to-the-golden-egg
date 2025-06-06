# WebView App

Приложение с WebView и красивым экраном загрузки.

## Установка

1. Убедитесь, что у вас установлены:
   - Node.js
   - npm или yarn
   - Xcode (для iOS)
   - Android Studio (для Android)

2. Установите зависимости:
```bash
npm install
# или
yarn install
```

3. Для iOS установите поды:
```bash
cd ios
pod install
cd ..
```

## Запуск приложения

### iOS
```bash
npm run ios
# или
yarn ios
```

### Android
```bash
npm run android
# или
yarn android
```

## Настройка

Для изменения URL веб-страницы, отредактируйте значение `uri` в компоненте WebView в файле `App.js`:

```javascript
<WebView
  source={{ uri: 'https://www.example.com' }} // Замените на нужный URL
  ...
/>
``` 