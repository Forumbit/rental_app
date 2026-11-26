// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Уютно';

  @override
  String get appTagline => 'Дома, коттеджи и квартиры для отдыха';

  @override
  String get navExplore => 'Поиск';

  @override
  String get navMyListings => 'Мои объявления';

  @override
  String get navProfile => 'Профиль';

  @override
  String get feedTitle => 'Найдите место для отдыха';

  @override
  String get feedSubtitle => 'Проверенные дома и квартиры от владельцев';

  @override
  String get feedEmptyTitle => 'Пока нет объявлений';

  @override
  String get feedEmptyBody =>
      'Загляните позже — владельцы уже готовят новые предложения.';

  @override
  String listingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count объявлений',
      few: '$count объявления',
      one: '$count объявление',
      zero: 'Нет объявлений',
    );
    return '$_temp0';
  }

  @override
  String get propertyHouse => 'Дом';

  @override
  String get propertyCottage => 'Коттедж';

  @override
  String get propertyDacha => 'Дача';

  @override
  String get propertyApartment => 'Квартира';

  @override
  String get statusDraft => 'Черновик';

  @override
  String get statusPublished => 'Опубликовано';

  @override
  String get statusArchived => 'В архиве';

  @override
  String get statusAll => 'Все';

  @override
  String get perDay => 'сутки';

  @override
  String get perMonth => 'месяц';

  @override
  String pricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String guests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гостей',
      few: '$count гостя',
      one: '$count гость',
    );
    return '$_temp0';
  }

  @override
  String bedrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count спален',
      few: '$count спальни',
      one: '$count спальня',
      zero: 'Студия',
    );
    return '$_temp0';
  }

  @override
  String bathrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count санузлов',
      few: '$count санузла',
      one: '$count санузел',
    );
    return '$_temp0';
  }

  @override
  String areaSqm(String area) {
    return '$area м²';
  }

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото',
      one: '$count фото',
      zero: 'Нет фото',
    );
    return '$_temp0';
  }

  @override
  String get detailsAbout => 'Описание';

  @override
  String get detailsFeatures => 'Характеристики';

  @override
  String get detailsLocation => 'Расположение';

  @override
  String detailsPublished(String date) {
    return 'Опубликовано $date';
  }

  @override
  String get detailsContact => 'Связаться с владельцем';

  @override
  String get detailsContactSoon => 'Бронирование и сообщения скоро появятся';

  @override
  String get detailsShowMore => 'Показать полностью';

  @override
  String get detailsShowLess => 'Свернуть';

  @override
  String get detailsYourListing => 'Это ваше объявление';

  @override
  String photoOf(int current, int total) {
    return '$current из $total';
  }

  @override
  String get myListingsEmptyTitle => 'Здесь появятся ваши объявления';

  @override
  String get myListingsEmptyBody =>
      'Расскажите о своём доме — это займёт пару минут.';

  @override
  String get myListingsFilterEmpty => 'В этом разделе пока пусто';

  @override
  String get newListing => 'Новое объявление';

  @override
  String get editListing => 'Редактирование';

  @override
  String get edit => 'Изменить';

  @override
  String get publish => 'Опубликовать';

  @override
  String get unpublish => 'Снять с публикации';

  @override
  String get archive => 'В архив';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get retry => 'Повторить';

  @override
  String get close => 'Закрыть';

  @override
  String get deleteListingTitle => 'Удалить объявление?';

  @override
  String deleteListingBody(String title) {
    return '«$title» и все его фото будут удалены без возможности восстановления.';
  }

  @override
  String get listingDeleted => 'Объявление удалено';

  @override
  String get listingSaved => 'Объявление сохранено';

  @override
  String get listingPublished => 'Объявление опубликовано';

  @override
  String get listingUnpublished => 'Объявление снято с публикации';

  @override
  String get formSectionPhotos => 'Фотографии';

  @override
  String formPhotosHint(int max) {
    return 'Первое фото — обложка. Перетаскивайте, чтобы изменить порядок. До $max фото, JPEG, PNG или WebP до 5 МБ.';
  }

  @override
  String get formAddPhotos => 'Добавить фото';

  @override
  String get formCover => 'Обложка';

  @override
  String get formSectionMain => 'Основное';

  @override
  String get formSectionPrice => 'Цена';

  @override
  String get formSectionLocation => 'Адрес';

  @override
  String get formSectionDetails => 'Параметры';

  @override
  String get formSectionVisibility => 'Видимость';

  @override
  String get formTitle => 'Заголовок';

  @override
  String get formTitleHint => 'Например, «Дом у озера с баней»';

  @override
  String get formDescription => 'Описание';

  @override
  String get formDescriptionHint => 'Что есть в доме, что рядом, кому подойдёт';

  @override
  String get formPropertyType => 'Тип жилья';

  @override
  String get formPrice => 'Цена';

  @override
  String get formCurrency => 'Валюта';

  @override
  String get formPeriod => 'За';

  @override
  String get formCountry => 'Страна';

  @override
  String get formRegion => 'Регион';

  @override
  String get formCity => 'Город или посёлок';

  @override
  String get formAddress => 'Адрес';

  @override
  String get formAddressHint =>
      'Улица и дом — увидят все, кто откроет объявление';

  @override
  String get formArea => 'Площадь, м²';

  @override
  String get formBedrooms => 'Спальни';

  @override
  String get formBathrooms => 'Санузлы';

  @override
  String get formMaxGuests => 'Гостей';

  @override
  String get formStatusHint => 'Черновики и архив видите только вы.';

  @override
  String get formRequired => 'Обязательное поле';

  @override
  String formTooLong(int max) {
    return 'Не больше $max символов';
  }

  @override
  String get formInvalidNumber => 'Введите число';

  @override
  String get formPricePositive => 'Цена должна быть больше нуля';

  @override
  String get formAreaRange => 'От 0,01 до 999 999,99';

  @override
  String get formSaving => 'Сохраняем…';

  @override
  String formUploadingPhoto(int current, int total) {
    return 'Загружаем фото $current из $total…';
  }

  @override
  String get formDiscardTitle => 'Отменить изменения?';

  @override
  String get formDiscardBody => 'Несохранённые изменения будут потеряны.';

  @override
  String get formDiscard => 'Не сохранять';

  @override
  String get formKeepEditing => 'Продолжить';

  @override
  String formPhotoTooLarge(String name) {
    return 'Фото «$name» больше 5 МБ';
  }

  @override
  String formPhotoLimit(int max) {
    return 'Можно добавить не больше $max фото';
  }

  @override
  String formPartialSave(String error) {
    return 'Объявление сохранено, но часть фото не загрузилась: $error';
  }

  @override
  String get loginTitle => 'С возвращением';

  @override
  String get loginSubtitle => 'Войдите, чтобы управлять своими объявлениями';

  @override
  String get email => 'Почта';

  @override
  String get password => 'Пароль';

  @override
  String get fullName => 'Имя и фамилия';

  @override
  String get passwordRepeat => 'Повторите пароль';

  @override
  String get login => 'Войти';

  @override
  String get logout => 'Выйти';

  @override
  String get register => 'Создать аккаунт';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get haveAccount => 'Уже есть аккаунт?';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get emailInvalid => 'Введите корректную почту';

  @override
  String get passwordTooShort => 'Минимум 8 символов';

  @override
  String get passwordTooLong => 'Слишком длинный пароль';

  @override
  String get passwordsDiffer => 'Пароли не совпадают';

  @override
  String get registerTitle => 'Создайте аккаунт';

  @override
  String get registerSubtitle =>
      'Сдавайте жильё и управляйте объявлениями в одном месте';

  @override
  String get verifyTitle => 'Подтвердите почту';

  @override
  String verifyBody(String email) {
    return 'Мы отправили 6-значный код на $email. Введите его или нажмите на ссылку в письме.';
  }

  @override
  String get verifyCode => 'Код из письма';

  @override
  String get verifySubmit => 'Подтвердить';

  @override
  String get verifyResend => 'Отправить код ещё раз';

  @override
  String verifyResendIn(int seconds) {
    return 'Отправить снова через $seconds с';
  }

  @override
  String get verifyResent => 'Новый код отправлен';

  @override
  String get verifyDone => 'Почта подтверждена. Теперь можно войти.';

  @override
  String get verifyCodeInvalid => 'Код состоит из 6 цифр';

  @override
  String get signInRequiredTitle => 'Войдите в аккаунт';

  @override
  String get signInRequiredBody =>
      'Чтобы размещать объявления и управлять ими, нужно войти или зарегистрироваться.';

  @override
  String get profileGuest => 'Гость';

  @override
  String get profileGuestBody => 'Войдите, чтобы размещать свои объявления';

  @override
  String profileMemberSince(String date) {
    return 'С нами с $date';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get about => 'О приложении';

  @override
  String get logoutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get logoutConfirmBody => 'Вы сможете войти снова в любой момент.';

  @override
  String get errorNetwork => 'Нет соединения с сервером. Проверьте интернет.';

  @override
  String get errorServer => 'Что-то пошло не так на сервере. Попробуйте позже.';

  @override
  String get errorNotFound =>
      'Не найдено — возможно, объявление удалили или сняли с публикации.';

  @override
  String get errorInvalidCredentials => 'Неверная почта или пароль';

  @override
  String get errorEmailNotVerified => 'Сначала подтвердите почту';

  @override
  String get errorEmailTaken => 'Эта почта уже зарегистрирована';

  @override
  String get errorMailUnavailable =>
      'Не удалось отправить письмо. Попробуйте позже.';

  @override
  String get errorTooManyRequests => 'Слишком часто. Подождите немного.';

  @override
  String get errorInvalidCode => 'Неверный или устаревший код';

  @override
  String get errorSessionExpired => 'Сессия истекла, войдите снова';

  @override
  String get errorTitle => 'Не удалось загрузить';

  @override
  String get notFoundTitle => 'Страница не найдена';
}
