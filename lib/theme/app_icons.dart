// lib/theme/app_icons.dart
import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';

/// Canonical icon names for your app
enum AppIcon {
  verified,
  shield,
  crown,
  copy,
  editProfile,
  changeMobile,
  updateExperience,
  changeLanguage,
  updatePreference,
  hiredJobs,
  paymentHistory,
  privacyPolicy,
  termsConditions,
  refundPolicy,
  rateReview,
  shareApp,
  deleteAccount,
  logout,

  jobs,
  applications,
  wishlist,
  profile,
  profileHiredJob,

  location,
  dateTime,
  call,
  hired,
  download,

  shareJob,
  bookmarkJob,
  jobInfo,
  salary,
  vacancy,
  company,
  time,
  jobFor,
  incentives,

  success,
  callFilled,
  notification,
  helpSupport,
  search,
  filter,
  jobTime,

  date,
  clear,
  attachment,
  addMore,

  verifyAadhar,
  selfiePhoto,

  profilePending,
  applied,
  shortlisted,
  rejected,
  expired,

  addStory,
  shortlist,
  addJob,
  jobType,
  edit,
  activeJob,
  helpSupportFilled,
}

/// Mapping from your app icon names to SolarIconPack icons
class AppIcons {
  static const Map<AppIcon, IconData> solar = {
    AppIcon.verified: SolarBoldIcons.verifiedCheck,
    AppIcon.shield: SolarBoldIcons.shieldCheck,
    AppIcon.crown: SolarLinearIcons.crown,
    AppIcon.copy: SolarLinearIcons.copy,
    AppIcon.editProfile: SolarBoldIcons.pen2,
    AppIcon.changeMobile: SolarBoldIcons.phone,
    AppIcon.updateExperience: SolarBoldIcons.clipboardList,
    AppIcon.changeLanguage: SolarBoldIcons.global,
    AppIcon.updatePreference: SolarBoldIcons.settings,
    AppIcon.hiredJobs: SolarLinearIcons.caseMinimalistic,
    AppIcon.paymentHistory: SolarBoldIcons.card,
    AppIcon.privacyPolicy: SolarBoldIcons.shieldMinimalistic,
    AppIcon.termsConditions: SolarBoldIcons.documentText,
    AppIcon.refundPolicy: SolarBoldIcons.dollarMinimalistic,
    AppIcon.rateReview: SolarBoldIcons.star,
    AppIcon.shareApp: SolarBoldIcons.share,
    AppIcon.deleteAccount: SolarBoldIcons.trashBin,
    AppIcon.logout: SolarBoldIcons.login,

    AppIcon.jobs: SolarBoldIcons.suitcase,
    AppIcon.applications: SolarBoldIcons.usersGroupRounded,
    AppIcon.wishlist: SolarBoldIcons.bookmark,
    AppIcon.profile: SolarBoldIcons.userCircle,

    AppIcon.location: SolarLinearIcons.mapPoint,
    AppIcon.dateTime: SolarLinearIcons.calendarMinimalistic,
    AppIcon.call: SolarLinearIcons.phone,
    AppIcon.hired: SolarBoldIcons.bolt,
    AppIcon.download: SolarBoldIcons.downloadMinimalistic,

    AppIcon.shareJob: SolarLinearIcons.share,
    AppIcon.bookmarkJob: SolarLinearIcons.bookmark,
    AppIcon.jobInfo: SolarLinearIcons.dangerCircle,
    AppIcon.salary: SolarLinearIcons.wadOfMoney,
    AppIcon.vacancy: SolarLinearIcons.usersGroupTwoRounded,
    AppIcon.company: SolarLinearIcons.buildings2,
    AppIcon.time: SolarLinearIcons.clockCircle,
    AppIcon.jobFor: SolarBoldIcons.suitcase,
    AppIcon.incentives: SolarBoldIcons.gift,

    AppIcon.success: SolarBoldIcons.checkCircle,
    AppIcon.callFilled: SolarBoldIcons.phone,
    AppIcon.notification: SolarLinearIcons.bell,
    AppIcon.helpSupport: SolarLinearIcons.questionCircle,
    AppIcon.helpSupportFilled: SolarBoldIcons.questionCircle,
    AppIcon.search: SolarLinearIcons.magnifer,
    AppIcon.filter: SolarLinearIcons.tuning2,
    AppIcon.jobTime: SolarLinearIcons.clockCircle,
    AppIcon.profileHiredJob: SolarBoldIcons.caseMinimalistic,

    AppIcon.date: SolarLinearIcons.calendar,
    AppIcon.clear: SolarLinearIcons.closeCircle,
    AppIcon.attachment: SolarBoldIcons.paperclip,
    AppIcon.addMore: SolarLinearIcons.addCircle,

    AppIcon.verifyAadhar: SolarLinearIcons.userId,
    AppIcon.selfiePhoto: SolarLinearIcons.faceScanSquare,

    AppIcon.profilePending: SolarBoldIcons.hourglass,
    AppIcon.applied: SolarBoldIcons.letterOpened,
    AppIcon.shortlisted: SolarBoldIcons.pin,
    AppIcon.rejected: SolarBoldIcons.slashCircle,
    AppIcon.expired: SolarBoldIcons.record,

    AppIcon.addStory: SolarBoldIcons.addCircle,
    AppIcon.shortlist: SolarLinearIcons.pin,
    AppIcon.addJob: SolarLinearIcons.addCircle,
    AppIcon.jobType: SolarLinearIcons.suitcase,
    AppIcon.edit: SolarLinearIcons.pen2,
    AppIcon.activeJob: SolarBoldIcons.record


  };
}
