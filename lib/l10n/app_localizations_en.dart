// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Uyutno';

  @override
  String get appTagline => 'Houses, cottages and apartments to stay';

  @override
  String get navExplore => 'Explore';

  @override
  String get navMyListings => 'My listings';

  @override
  String get navProfile => 'Profile';

  @override
  String get feedTitle => 'Find your place to stay';

  @override
  String get feedSubtitle => 'Homes and apartments straight from their owners';

  @override
  String get feedEmptyTitle => 'No listings yet';

  @override
  String get feedEmptyBody =>
      'Check back later — owners are preparing new places.';

  @override
  String listingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listings',
      one: '$count listing',
      zero: 'No listings',
    );
    return '$_temp0';
  }

  @override
  String get propertyHouse => 'House';

  @override
  String get propertyCottage => 'Cottage';

  @override
  String get propertyDacha => 'Dacha';

  @override
  String get propertyApartment => 'Apartment';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPublished => 'Published';

  @override
  String get statusArchived => 'Archived';

  @override
  String get statusAll => 'All';

  @override
  String get perDay => 'night';

  @override
  String get perMonth => 'month';

  @override
  String pricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String guests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '$count guest',
    );
    return '$_temp0';
  }

  @override
  String bedrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bedrooms',
      one: '$count bedroom',
      zero: 'Studio',
    );
    return '$_temp0';
  }

  @override
  String bathrooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bathrooms',
      one: '$count bathroom',
    );
    return '$_temp0';
  }

  @override
  String areaSqm(String area) {
    return '$area m²';
  }

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '$count photo',
      zero: 'No photos',
    );
    return '$_temp0';
  }

  @override
  String get detailsAbout => 'About';

  @override
  String get detailsFeatures => 'Details';

  @override
  String get detailsLocation => 'Location';

  @override
  String detailsPublished(String date) {
    return 'Published $date';
  }

  @override
  String get detailsContact => 'Contact the owner';

  @override
  String get detailsContactSoon => 'Booking and messages are coming soon';

  @override
  String get detailsShowMore => 'Show more';

  @override
  String get detailsShowLess => 'Show less';

  @override
  String get detailsYourListing => 'This is your listing';

  @override
  String photoOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get myListingsEmptyTitle => 'Your listings will appear here';

  @override
  String get myListingsEmptyBody =>
      'Tell guests about your place — it takes a couple of minutes.';

  @override
  String get myListingsFilterEmpty => 'Nothing here yet';

  @override
  String get newListing => 'New listing';

  @override
  String get editListing => 'Edit listing';

  @override
  String get edit => 'Edit';

  @override
  String get publish => 'Publish';

  @override
  String get unpublish => 'Unpublish';

  @override
  String get archive => 'Archive';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get deleteListingTitle => 'Delete listing?';

  @override
  String deleteListingBody(String title) {
    return '“$title” and all its photos will be deleted permanently.';
  }

  @override
  String get listingDeleted => 'Listing deleted';

  @override
  String get listingSaved => 'Listing saved';

  @override
  String get listingPublished => 'Listing published';

  @override
  String get listingUnpublished => 'Listing unpublished';

  @override
  String get formSectionPhotos => 'Photos';

  @override
  String formPhotosHint(int max) {
    return 'The first photo is the cover. Drag to reorder. Up to $max photos, JPEG, PNG or WebP up to 5 MB.';
  }

  @override
  String get formAddPhotos => 'Add photos';

  @override
  String get formCover => 'Cover';

  @override
  String get formSectionMain => 'Basics';

  @override
  String get formSectionPrice => 'Price';

  @override
  String get formSectionLocation => 'Address';

  @override
  String get formSectionDetails => 'Details';

  @override
  String get formSectionVisibility => 'Visibility';

  @override
  String get formTitle => 'Title';

  @override
  String get formTitleHint => 'E.g. “Lake house with a sauna”';

  @override
  String get formDescription => 'Description';

  @override
  String get formDescriptionHint =>
      'What\'s inside, what\'s nearby, who it\'s for';

  @override
  String get formPropertyType => 'Property type';

  @override
  String get formPrice => 'Price';

  @override
  String get formCurrency => 'Currency';

  @override
  String get formPeriod => 'Per';

  @override
  String get formCountry => 'Country';

  @override
  String get formRegion => 'Region';

  @override
  String get formCity => 'City or village';

  @override
  String get formAddress => 'Address';

  @override
  String get formAddressHint => 'Street and house — visible to everyone';

  @override
  String get formArea => 'Area, m²';

  @override
  String get formBedrooms => 'Bedrooms';

  @override
  String get formBathrooms => 'Bathrooms';

  @override
  String get formMaxGuests => 'Guests';

  @override
  String get formStatusHint => 'Only you can see drafts and archived listings.';

  @override
  String get formRequired => 'Required';

  @override
  String formTooLong(int max) {
    return 'At most $max characters';
  }

  @override
  String get formInvalidNumber => 'Enter a number';

  @override
  String get formPricePositive => 'Price must be greater than zero';

  @override
  String get formAreaRange => 'From 0.01 to 999,999.99';

  @override
  String get formSaving => 'Saving…';

  @override
  String formUploadingPhoto(int current, int total) {
    return 'Uploading photo $current of $total…';
  }

  @override
  String get formDiscardTitle => 'Discard changes?';

  @override
  String get formDiscardBody => 'Unsaved changes will be lost.';

  @override
  String get formDiscard => 'Discard';

  @override
  String get formKeepEditing => 'Keep editing';

  @override
  String formPhotoTooLarge(String name) {
    return 'Photo “$name” is larger than 5 MB';
  }

  @override
  String formPhotoLimit(int max) {
    return 'You can add up to $max photos';
  }

  @override
  String formPartialSave(String error) {
    return 'Listing saved, but some photos failed to upload: $error';
  }

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your listings';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get passwordRepeat => 'Repeat password';

  @override
  String get login => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get register => 'Create account';

  @override
  String get noAccount => 'No account yet?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordTooShort => 'At least 8 characters';

  @override
  String get passwordTooLong => 'Password is too long';

  @override
  String get passwordsDiffer => 'Passwords don\'t match';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'List your place and manage it in one app';

  @override
  String get verifyTitle => 'Confirm your email';

  @override
  String verifyBody(String email) {
    return 'We sent a 6-digit code to $email. Enter it or tap the link in the email.';
  }

  @override
  String get verifyCode => 'Code from the email';

  @override
  String get verifySubmit => 'Confirm';

  @override
  String get verifyResend => 'Send the code again';

  @override
  String verifyResendIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get verifyResent => 'A new code is on its way';

  @override
  String get verifyDone => 'Email confirmed. You can sign in now.';

  @override
  String get verifyCodeInvalid => 'The code has 6 digits';

  @override
  String get signInRequiredTitle => 'Sign in to continue';

  @override
  String get signInRequiredBody =>
      'Sign in or create an account to list and manage your places.';

  @override
  String get profileGuest => 'Guest';

  @override
  String get profileGuestBody => 'Sign in to list your own places';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get about => 'About';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmBody => 'You can sign in again at any time.';

  @override
  String get errorNetwork => 'Can\'t reach the server. Check your connection.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Try again later.';

  @override
  String get errorNotFound =>
      'Not found — the listing may have been removed or unpublished.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password';

  @override
  String get errorEmailNotVerified => 'Confirm your email first';

  @override
  String get errorEmailTaken => 'This email is already registered';

  @override
  String get errorMailUnavailable =>
      'Couldn\'t send the email. Try again later.';

  @override
  String get errorTooManyRequests => 'Too many attempts. Please wait a bit.';

  @override
  String get errorInvalidCode => 'Wrong or expired code';

  @override
  String get errorSessionExpired =>
      'Your session has expired, please sign in again';

  @override
  String get errorTitle => 'Couldn\'t load';

  @override
  String get notFoundTitle => 'Page not found';
}
