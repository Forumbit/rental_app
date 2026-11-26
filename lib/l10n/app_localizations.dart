import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уютно'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ru, this message translates to:
  /// **'Дома, коттеджи и квартиры для отдыха'**
  String get appTagline;

  /// No description provided for @navExplore.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get navExplore;

  /// No description provided for @navMyListings.
  ///
  /// In ru, this message translates to:
  /// **'Мои объявления'**
  String get navMyListings;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @feedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Найдите место для отдыха'**
  String get feedTitle;

  /// No description provided for @feedSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверенные дома и квартиры от владельцев'**
  String get feedSubtitle;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет объявлений'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Загляните позже — владельцы уже готовят новые предложения.'**
  String get feedEmptyBody;

  /// No description provided for @listingsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет объявлений} one{{count} объявление} few{{count} объявления} other{{count} объявлений}}'**
  String listingsCount(int count);

  /// No description provided for @propertyHouse.
  ///
  /// In ru, this message translates to:
  /// **'Дом'**
  String get propertyHouse;

  /// No description provided for @propertyCottage.
  ///
  /// In ru, this message translates to:
  /// **'Коттедж'**
  String get propertyCottage;

  /// No description provided for @propertyDacha.
  ///
  /// In ru, this message translates to:
  /// **'Дача'**
  String get propertyDacha;

  /// No description provided for @propertyApartment.
  ///
  /// In ru, this message translates to:
  /// **'Квартира'**
  String get propertyApartment;

  /// No description provided for @statusDraft.
  ///
  /// In ru, this message translates to:
  /// **'Черновик'**
  String get statusDraft;

  /// No description provided for @statusPublished.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовано'**
  String get statusPublished;

  /// No description provided for @statusArchived.
  ///
  /// In ru, this message translates to:
  /// **'В архиве'**
  String get statusArchived;

  /// No description provided for @statusAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get statusAll;

  /// No description provided for @perDay.
  ///
  /// In ru, this message translates to:
  /// **'сутки'**
  String get perDay;

  /// No description provided for @perMonth.
  ///
  /// In ru, this message translates to:
  /// **'месяц'**
  String get perMonth;

  /// No description provided for @pricePer.
  ///
  /// In ru, this message translates to:
  /// **'{price} / {period}'**
  String pricePer(String price, String period);

  /// No description provided for @guests.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} гость} few{{count} гостя} other{{count} гостей}}'**
  String guests(int count);

  /// No description provided for @bedrooms.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Студия} one{{count} спальня} few{{count} спальни} other{{count} спален}}'**
  String bedrooms(int count);

  /// No description provided for @bathrooms.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} санузел} few{{count} санузла} other{{count} санузлов}}'**
  String bathrooms(int count);

  /// No description provided for @areaSqm.
  ///
  /// In ru, this message translates to:
  /// **'{area} м²'**
  String areaSqm(String area);

  /// No description provided for @photosCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет фото} one{{count} фото} other{{count} фото}}'**
  String photosCount(int count);

  /// No description provided for @detailsAbout.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get detailsAbout;

  /// No description provided for @detailsFeatures.
  ///
  /// In ru, this message translates to:
  /// **'Характеристики'**
  String get detailsFeatures;

  /// No description provided for @detailsLocation.
  ///
  /// In ru, this message translates to:
  /// **'Расположение'**
  String get detailsLocation;

  /// No description provided for @detailsPublished.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовано {date}'**
  String detailsPublished(String date);

  /// No description provided for @detailsContact.
  ///
  /// In ru, this message translates to:
  /// **'Связаться с владельцем'**
  String get detailsContact;

  /// No description provided for @detailsContactSoon.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование и сообщения скоро появятся'**
  String get detailsContactSoon;

  /// No description provided for @detailsShowMore.
  ///
  /// In ru, this message translates to:
  /// **'Показать полностью'**
  String get detailsShowMore;

  /// No description provided for @detailsShowLess.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть'**
  String get detailsShowLess;

  /// No description provided for @detailsYourListing.
  ///
  /// In ru, this message translates to:
  /// **'Это ваше объявление'**
  String get detailsYourListing;

  /// No description provided for @photoOf.
  ///
  /// In ru, this message translates to:
  /// **'{current} из {total}'**
  String photoOf(int current, int total);

  /// No description provided for @myListingsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся ваши объявления'**
  String get myListingsEmptyTitle;

  /// No description provided for @myListingsEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Расскажите о своём доме — это займёт пару минут.'**
  String get myListingsEmptyBody;

  /// No description provided for @myListingsFilterEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В этом разделе пока пусто'**
  String get myListingsFilterEmpty;

  /// No description provided for @newListing.
  ///
  /// In ru, this message translates to:
  /// **'Новое объявление'**
  String get newListing;

  /// No description provided for @editListing.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование'**
  String get editListing;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @publish.
  ///
  /// In ru, this message translates to:
  /// **'Опубликовать'**
  String get publish;

  /// No description provided for @unpublish.
  ///
  /// In ru, this message translates to:
  /// **'Снять с публикации'**
  String get unpublish;

  /// No description provided for @archive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get archive;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @deleteListingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить объявление?'**
  String get deleteListingTitle;

  /// No description provided for @deleteListingBody.
  ///
  /// In ru, this message translates to:
  /// **'«{title}» и все его фото будут удалены без возможности восстановления.'**
  String deleteListingBody(String title);

  /// No description provided for @listingDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Объявление удалено'**
  String get listingDeleted;

  /// No description provided for @listingSaved.
  ///
  /// In ru, this message translates to:
  /// **'Объявление сохранено'**
  String get listingSaved;

  /// No description provided for @listingPublished.
  ///
  /// In ru, this message translates to:
  /// **'Объявление опубликовано'**
  String get listingPublished;

  /// No description provided for @listingUnpublished.
  ///
  /// In ru, this message translates to:
  /// **'Объявление снято с публикации'**
  String get listingUnpublished;

  /// No description provided for @formSectionPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фотографии'**
  String get formSectionPhotos;

  /// No description provided for @formPhotosHint.
  ///
  /// In ru, this message translates to:
  /// **'Первое фото — обложка. Перетаскивайте, чтобы изменить порядок. До {max} фото, JPEG, PNG или WebP до 5 МБ.'**
  String formPhotosHint(int max);

  /// No description provided for @formAddPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get formAddPhotos;

  /// No description provided for @formCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложка'**
  String get formCover;

  /// No description provided for @formSectionMain.
  ///
  /// In ru, this message translates to:
  /// **'Основное'**
  String get formSectionMain;

  /// No description provided for @formSectionPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get formSectionPrice;

  /// No description provided for @formSectionLocation.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get formSectionLocation;

  /// No description provided for @formSectionDetails.
  ///
  /// In ru, this message translates to:
  /// **'Параметры'**
  String get formSectionDetails;

  /// No description provided for @formSectionVisibility.
  ///
  /// In ru, this message translates to:
  /// **'Видимость'**
  String get formSectionVisibility;

  /// No description provided for @formTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заголовок'**
  String get formTitle;

  /// No description provided for @formTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, «Дом у озера с баней»'**
  String get formTitleHint;

  /// No description provided for @formDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get formDescription;

  /// No description provided for @formDescriptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Что есть в доме, что рядом, кому подойдёт'**
  String get formDescriptionHint;

  /// No description provided for @formPropertyType.
  ///
  /// In ru, this message translates to:
  /// **'Тип жилья'**
  String get formPropertyType;

  /// No description provided for @formPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get formPrice;

  /// No description provided for @formCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get formCurrency;

  /// No description provided for @formPeriod.
  ///
  /// In ru, this message translates to:
  /// **'За'**
  String get formPeriod;

  /// No description provided for @formCountry.
  ///
  /// In ru, this message translates to:
  /// **'Страна'**
  String get formCountry;

  /// No description provided for @formRegion.
  ///
  /// In ru, this message translates to:
  /// **'Регион'**
  String get formRegion;

  /// No description provided for @formCity.
  ///
  /// In ru, this message translates to:
  /// **'Город или посёлок'**
  String get formCity;

  /// No description provided for @formAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get formAddress;

  /// No description provided for @formAddressHint.
  ///
  /// In ru, this message translates to:
  /// **'Улица и дом — увидят все, кто откроет объявление'**
  String get formAddressHint;

  /// No description provided for @formArea.
  ///
  /// In ru, this message translates to:
  /// **'Площадь, м²'**
  String get formArea;

  /// No description provided for @formBedrooms.
  ///
  /// In ru, this message translates to:
  /// **'Спальни'**
  String get formBedrooms;

  /// No description provided for @formBathrooms.
  ///
  /// In ru, this message translates to:
  /// **'Санузлы'**
  String get formBathrooms;

  /// No description provided for @formMaxGuests.
  ///
  /// In ru, this message translates to:
  /// **'Гостей'**
  String get formMaxGuests;

  /// No description provided for @formStatusHint.
  ///
  /// In ru, this message translates to:
  /// **'Черновики и архив видите только вы.'**
  String get formStatusHint;

  /// No description provided for @formRequired.
  ///
  /// In ru, this message translates to:
  /// **'Обязательное поле'**
  String get formRequired;

  /// No description provided for @formTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Не больше {max} символов'**
  String formTooLong(int max);

  /// No description provided for @formInvalidNumber.
  ///
  /// In ru, this message translates to:
  /// **'Введите число'**
  String get formInvalidNumber;

  /// No description provided for @formPricePositive.
  ///
  /// In ru, this message translates to:
  /// **'Цена должна быть больше нуля'**
  String get formPricePositive;

  /// No description provided for @formAreaRange.
  ///
  /// In ru, this message translates to:
  /// **'От 0,01 до 999 999,99'**
  String get formAreaRange;

  /// No description provided for @formSaving.
  ///
  /// In ru, this message translates to:
  /// **'Сохраняем…'**
  String get formSaving;

  /// No description provided for @formUploadingPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем фото {current} из {total}…'**
  String formUploadingPhoto(int current, int total);

  /// No description provided for @formDiscardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отменить изменения?'**
  String get formDiscardTitle;

  /// No description provided for @formDiscardBody.
  ///
  /// In ru, this message translates to:
  /// **'Несохранённые изменения будут потеряны.'**
  String get formDiscardBody;

  /// No description provided for @formDiscard.
  ///
  /// In ru, this message translates to:
  /// **'Не сохранять'**
  String get formDiscard;

  /// No description provided for @formKeepEditing.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get formKeepEditing;

  /// No description provided for @formPhotoTooLarge.
  ///
  /// In ru, this message translates to:
  /// **'Фото «{name}» больше 5 МБ'**
  String formPhotoTooLarge(String name);

  /// No description provided for @formPhotoLimit.
  ///
  /// In ru, this message translates to:
  /// **'Можно добавить не больше {max} фото'**
  String formPhotoLimit(int max);

  /// No description provided for @formPartialSave.
  ///
  /// In ru, this message translates to:
  /// **'Объявление сохранено, но часть фото не загрузилась: {error}'**
  String formPartialSave(String error);

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'С возвращением'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы управлять своими объявлениями'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Почта'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In ru, this message translates to:
  /// **'Имя и фамилия'**
  String get fullName;

  /// No description provided for @passwordRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get passwordRepeat;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get register;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get haveAccount;

  /// No description provided for @showPassword.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get hidePassword;

  /// No description provided for @emailInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректную почту'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 8 символов'**
  String get passwordTooShort;

  /// No description provided for @passwordTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Слишком длинный пароль'**
  String get passwordTooLong;

  /// No description provided for @passwordsDiffer.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsDiffer;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте аккаунт'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сдавайте жильё и управляйте объявлениями в одном месте'**
  String get registerSubtitle;

  /// No description provided for @verifyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите почту'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправили 6-значный код на {email}. Введите его или нажмите на ссылку в письме.'**
  String verifyBody(String email);

  /// No description provided for @verifyCode.
  ///
  /// In ru, this message translates to:
  /// **'Код из письма'**
  String get verifyCode;

  /// No description provided for @verifySubmit.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get verifySubmit;

  /// No description provided for @verifyResend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код ещё раз'**
  String get verifyResend;

  /// No description provided for @verifyResendIn.
  ///
  /// In ru, this message translates to:
  /// **'Отправить снова через {seconds} с'**
  String verifyResendIn(int seconds);

  /// No description provided for @verifyResent.
  ///
  /// In ru, this message translates to:
  /// **'Новый код отправлен'**
  String get verifyResent;

  /// No description provided for @verifyDone.
  ///
  /// In ru, this message translates to:
  /// **'Почта подтверждена. Теперь можно войти.'**
  String get verifyDone;

  /// No description provided for @verifyCodeInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Код состоит из 6 цифр'**
  String get verifyCodeInvalid;

  /// No description provided for @signInRequiredTitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в аккаунт'**
  String get signInRequiredTitle;

  /// No description provided for @signInRequiredBody.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы размещать объявления и управлять ими, нужно войти или зарегистрироваться.'**
  String get signInRequiredBody;

  /// No description provided for @profileGuest.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get profileGuest;

  /// No description provided for @profileGuestBody.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы размещать свои объявления'**
  String get profileGuestBody;

  /// No description provided for @profileMemberSince.
  ///
  /// In ru, this message translates to:
  /// **'С нами с {date}'**
  String profileMemberSince(String date);

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In ru, this message translates to:
  /// **'Вы сможете войти снова в любой момент.'**
  String get logoutConfirmBody;

  /// No description provided for @errorNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения с сервером. Проверьте интернет.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так на сервере. Попробуйте позже.'**
  String get errorServer;

  /// No description provided for @errorNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено — возможно, объявление удалили или сняли с публикации.'**
  String get errorNotFound;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверная почта или пароль'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailNotVerified.
  ///
  /// In ru, this message translates to:
  /// **'Сначала подтвердите почту'**
  String get errorEmailNotVerified;

  /// No description provided for @errorEmailTaken.
  ///
  /// In ru, this message translates to:
  /// **'Эта почта уже зарегистрирована'**
  String get errorEmailTaken;

  /// No description provided for @errorMailUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить письмо. Попробуйте позже.'**
  String get errorMailUnavailable;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In ru, this message translates to:
  /// **'Слишком часто. Подождите немного.'**
  String get errorTooManyRequests;

  /// No description provided for @errorInvalidCode.
  ///
  /// In ru, this message translates to:
  /// **'Неверный или устаревший код'**
  String get errorInvalidCode;

  /// No description provided for @errorSessionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сессия истекла, войдите снова'**
  String get errorSessionExpired;

  /// No description provided for @errorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить'**
  String get errorTitle;

  /// No description provided for @notFoundTitle.
  ///
  /// In ru, this message translates to:
  /// **'Страница не найдена'**
  String get notFoundTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
