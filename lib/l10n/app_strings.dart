/// All user-facing copy — Persian (fa-IR).
abstract final class AppStrings {
  // Brand / app
  static const appTitle = 'Shen AI';
  static const brandMark = 'Shen AI';

  // Startup
  static const heroTitle = 'سلامت خود را\nبشناسید.';
  static const heroSubtitle =
      'اسکن ۳۰ ثانیه‌ای چهره برای ضربان قلب، فشار خون، تنفس و شاخص‌های سلامتی — به‌صورت خصوصی روی دستگاه شما.';
  static const beginScan = 'شروع اسکن';
  static const tryAgain = 'تلاش دوباره';
  static const viewSampleReport = 'مشاهده گزارش نمونه';
  static const sampleReportHint = 'بدون دوربین و SDK — فقط پیش‌نمایش UI';
  static const cameraPrivacyHint =
      'دسترسی به دوربین لازم است · داده‌ها روی دستگاه می‌مانند';

  static const statusReady = 'آماده وقتی شما باشید';
  static const statusChecking = 'در حال بررسی تنظیمات…';
  static const statusCameraPermission = 'درخواست دسترسی به دوربین…';
  static const statusInitializing = 'در حال راه‌اندازی Shen AI…';
  static const statusOpeningScan = 'باز کردن صفحه اسکن…';

  static const errorMissingApiKey =
      'کلید API موبایل تنظیم نشده. ShenaiConfig.apiKey را مقداردهی کنید یا '
      '--dart-define=SHENAI_API_KEY=<key> را پاس دهید.';
  static const errorUnsupportedPlatform =
      'SDK فلاتر Shen AI فقط از اندروید و iOS پشتیبانی می‌کند.\n'
      'روی گوشی یا شبیه‌ساز اجرا کنید.';
  static const errorCameraPermanentlyDenied =
      'دسترسی دوربین برای همیشه رد شده است. '
      'دوربین را در تنظیمات فعال کنید و دوباره تلاش کنید.';
  static const errorCameraDenied = 'دسترسی به دوربین رد شد.';
  static String errorInitFailed(String name) => 'راه‌اندازی ناموفق: $name';
  static String errorStartup(Object error) => 'خطای راه‌اندازی: $error';

  // Measure
  static const liveScan = 'اسکن زنده';
  static const active = 'فعال';
  static const idle = 'آماده';
  static const preparingCamera = 'آماده‌سازی دوربین…';
  static const cameraUnavailable = 'دوربین در دسترس نیست';
  static const start = 'شروع';
  static const stop = 'توقف';
  static const viewResults = 'مشاهده نتایج';
  static const liveMetrics = 'شاخص‌های زنده';

  static const scanComplete = 'اسکن کامل شد';
  static const finalizingResults = 'در حال نهایی‌سازی نتایج…';
  static const finalizing = 'در حال نهایی‌سازی…';
  static const centerFace = 'صورت خود را در کادر قرار دهید';
  static const holdStill = 'ثابت بمانید — در حال اندازه‌گیری';
  static const scanFailed = 'اسکن ناموفق بود';
  static const readyToBegin = 'آماده برای شروع';
  static const finished = 'پایان یافت';

  static const uncoverForehead = 'پیشانی خود را باز کنید';
  static const removeGlasses = 'عینک را بردارید';
  static const brighterLight = 'به نور روشن‌تر بروید';
  static const evenLighting = 'از نور یکنواخت استفاده کنید';
  static const avoidBacklight = 'از نور پشت سر اجتناب کنید';
  static const keepFaceStill = 'صورت خود را ثابت نگه دارید';
  static const keepPhoneStill = 'گوشی را ثابت نگه دارید';

  // Metrics
  static const heartRate = 'ضربان قلب';
  static const systolic = 'سیستولیک';
  static const diastolic = 'دیاستولیک';
  static const breathing = 'تنفس';
  static const breathingRate = 'نرخ تنفس';
  static const stress = 'استرس';
  static const stressIndex = 'شاخص استرس';
  static const signalQuality = 'کیفیت سیگنال';
  static const hrvSdnn = 'نوسان‌پذیری ضربان (SDNN)';
  static const systolicBp = 'فشار سیستولیک';
  static const diastolicBp = 'فشار دیاستولیک';

  static const unitBpm = 'ضربان/دقیقه';
  static const unitMmHg = 'میلی‌متر جیوه';
  static const unitBrpm = 'تنفس/دقیقه';
  static const unitMs = 'میلی‌ثانیه';
  static const unitIndex = 'شاخص';
  static const unitYears = 'سال';
  static const unitKcal = 'کیلوکالری';
  static const unitPercent = '%';

  // Results
  static const results = 'نتایج';
  static const yourVitals = 'شاخص‌های حیاتی شما';
  static const capturedFromScan = 'ثبت‌شده از اسکن چهره شما.';
  static const fullMeasurement = 'اندازه‌گیری کامل';
  static const healthIndices = 'شاخص‌های سلامت';
  static const unlockHealthIndices =
      'با تکمیل اطلاعات پایه (سن، قد، وزن و …) شاخص‌های سلامت را ببینید. '
      'آزمایش‌های خونی اختیاری‌اند — اگر آن‌ها را نمی‌دانید می‌توانید خالی بگذارید.';
  static const computedHealthIndices =
      'محاسبه‌شده با API شاخص‌های سلامت Shen AI. '
      'شاخص‌هایی که دادهٔ کافی نداشته‌اند با علت کمبود مشخص شده‌اند.';
  static const calculateIndices = 'محاسبه شاخص‌ها';
  static const recalculate = 'محاسبه مجدد';
  static String errorComputeRisks(Object error) =>
      'محاسبه شاخص‌های سلامت ممکن نشد: $error';

  static const notCalculated = 'محاسبه نشد';
  static String notCalculatedBecause(String missing) =>
      'محاسبه نشد به‌خاطر کمبود داده: $missing';
  static const insufficientData = 'دادهٔ کافی برای این شاخص';
  static const diabetesNeedsLabsOrWaist =
      'دور کمر، یا قند ناشتا و HDL و تری‌گلیسیرید';
  static const optionalSectionHint =
      'اختیاری — اگر نمی‌دانید خالی بگذارید. بعضی شاخص‌ها بدون این مقادیر محاسبه نمی‌شوند.';
  static const requiredSectionHint = 'الزامی برای شروع محاسبه';
  static const sectionOptionalLabs = 'آزمایش‌های خونی (اختیاری)';
  static const sectionOptionalBody = 'اندازه‌گیری‌های تکمیلی بدن (اختیاری)';
  static const skippedIndices = 'شاخص‌های محاسبه‌نشده';
  static const computedIndices = 'شاخص‌های محاسبه‌شده';

  static const vascularAge = 'سن عروقی';
  static const wellnessScore = 'امتیاز تندرستی';
  static const cvdOverallRisk = 'ریسک کلی بیماری‌های قلبی‌عروقی';
  static const coronaryHeartDisease = 'بیماری عروق کرونر';
  static const strokeRisk = 'ریسک سکته مغزی';
  static const heartFailureRisk = 'ریسک نارسایی قلبی';
  static const peripheralVascularDisease = 'بیماری عروق محیطی';
  static const hardCvEventRisk = 'ریسک رویداد قلبی‌عروقی شدید';
  static const totalCvMortality = 'مرگ‌ومیر قلبی‌عروقی کل';
  static const hypertensionRisk = 'ریسک فشار خون بالا';
  static const diabetesRisk = 'ریسک دیابت';
  static const bodyFat = 'چربی بدن';
  static const waistToHeight = 'نسبت دور کمر به قد';
  static const bodyRoundnessIndex = 'شاخص گردی بدن';
  static const aBodyShapeIndex = 'شاخص شکل بدن';
  static const conicityIndex = 'شاخص مخروطی';
  static const bmr = 'نرخ متابولیسم پایه';
  static const tdee = 'مصرف انرژی روزانه';
  static const nafldRisk = 'ریسک کبد چرب غیرالکلی';

  // Health report (post data-entry)
  static const healthRiskIndices = 'شاخص‌های ریسک سلامت';
  static const bodyCompositionSection = 'ترکیب بدن و شاخص‌های متابولیک';
  static const riskLevel = 'سطح ریسک';
  static const years = 'سال';
  static const riskLow = 'کم';
  static const riskModerate = 'متوسط';
  static const riskElevated = 'نسبتاً بالا';
  static const riskHigh = 'بالا';
  static const yourStatus = 'وضعیت شما';
  static const chronologicalAge = 'سن تقویمی';
  static String yearsYounger(int years) => '$years سال جوان‌تر از سن واقعی — مطلوب';
  static String yearsOlder(int years) => '$years سال مسن‌تر از سن واقعی — نیاز به توجه';
  static const vascularAgeSame = 'تقریباً برابر سن تقویمی شما';
  static const scalePercentCvd =
      'احتمال تقریبی در بازهٔ زمانی مدل · نوار تا حدود ۲۰٪ مقیاس شده است';
  static const scalePercentHard =
      'احتمال تقریبی رویداد شدید · نوار تا حدود ۱۵٪ مقیاس شده است';
  static const scaleScore =
      'امتیاز تجمعی عوامل خطر · معمولاً از حدود −۵ (بهتر) تا ۲۰+ (ریسک بالاتر)';
  static const scaleWhtr =
      'زیر ۰٫۵ معمولاً مطلوب‌تر · نزدیک به ۰٫۶ و بالاتر ریسک بیشتر';
  static const scaleBfp =
      'بسته به جنس متفاوت است · درصدهای خیلی بالا معمولاً نامطلوب‌اند';
  static const scaleBri =
      'مقیاس تقریبی ۱ تا ۸ · عدد بالاتر معمولاً ریسک متابولیک بیشتر';
  static const scaleAbsi =
      'مقیاس تقریبی ۰٫۰۶ تا ۰٫۱۰ · عدد بالاتر معمولاً نامطلوب‌تر';
  static const scaleConicity =
      'مقیاس تقریبی ۱٫۰ تا ۱٫۵ · عدد بالاتر یعنی چاقی شکمی بیشتر';
  static const scaleWellness =
      'از ۰ تا ۱۰۰ · عدد بالاتر یعنی وضعیت تندرستی بهتر';
  static const scaleBmr =
      'کیلوکالری در روز · انرژی پایه برای زنده ماندن در حالت استراحت';
  static const scaleTdee =
      'کیلوکالری در روز · کل انرژی مصرفی با درنظرگرفتن فعالیت';
  static const scaleHypertension =
      'احتمال ابتلا · عدد پایین‌تر مطلوب‌تر است';
  static const scaleDiabetes =
      'احتمال ابتلا · عدد پایین‌تر مطلوب‌تر است';
  static const scaleNafld =
      'سطح ریسک کیفی · کم، متوسط یا زیاد';
  static const higherIsBetter = 'عدد بالاتر بهتر است';
  static const lowerIsBetter = 'عدد پایین‌تر بهتر است';

  static const vascularAgeDesc =
      'سن عروقی، سن واقعی شریان‌های شما را نشان می‌دهد و می‌تواند با سن تقویمی متفاوت باشد. '
      'سن عروقی بالاتر از سن واقعی می‌تواند نشانهٔ افزایش ریسک قلبی‌عروقی باشد.';
  static const cvdRiskTitle = 'ریسک بیماری‌های قلبی‌عروقی';
  static const cvdRiskDesc =
      'احتمال ابتلا به بیماری‌های قلبی‌عروقی شامل بیماری عروق کرونر، سکته مغزی، '
      'نارسایی قلبی و بیماری عروق محیطی را برآورد می‌کند.';
  static const hardFatalTitle = 'ریسک رویدادهای شدید و مرگبار';
  static const hardFatalDesc =
      'احتمال رویدادهای قلبی‌عروقی شدید مانند حمله قلبی یا سکته مغزی مرگبار را برآورد می‌کند.';
  static const chip10yCoronaryDeath = 'ریسک ۱۰ساله مرگ کرونری';
  static const chip10yFatalStroke = 'ریسک ۱۰ساله سکته مرگبار';
  static const cvRiskScoreTitle = 'امتیاز ریسک قلبی‌عروقی';
  static const cvRiskScoreDesc =
      'امتیاز کلی بر اساس عوامل خطر مانند سن، فشار خون، کلسترول، سیگار و دیابت. '
      'امتیاز بالاتر به‌معنی ریسک بیشتر است.';
  static const scoreAge = 'سن';
  static const scoreSex = 'جنس';
  static const scoreBp = 'فشار خون';
  static const scoreCholesterol = 'کلسترول';
  static const scoreHdl = 'HDL';
  static const scoreSmoking = 'سیگار';
  static const scoreDiabetes = 'دیابت';
  static const scoreBmi = 'BMI';

  static const whtrTitle = 'نسبت دور کمر به قد (WHtR)';
  static const whtrDesc =
      'نسبت دور کمر به قد، شاخصی برای چاقی شکمی و توزیع چربی است و با ریسک متابولیک مرتبط است.';
  static const bfpTitle = 'درصد چربی بدن (BFP)';
  static const bfpDesc =
      'درصد چربی بدن، سهم بافت چربی از وزن کل بدن را نشان می‌دهد و برای ارزیابی ترکیب بدن مفید است.';
  static const briTitle = 'شاخص گردی بدن (BRI)';
  static const briDesc =
      'شاخص گردی بدن شکل بدن را بر اساس قد و دور کمر توصیف می‌کند و با ریسک قلبی‌متابولیک مرتبط است.';
  static const absiTitle = 'شاخص شکل بدن (ABSI)';
  static const absiDesc =
      'شاخص شکل بدن، دور کمر را نسبت به قد و وزن می‌سنجد و می‌تواند ریسک مرگ‌ومیر را بهتر از BMI منعکس کند.';
  static const conicityTitle = 'شاخص مخروطی (CI)';
  static const conicityDesc =
      'شاخص مخروطی، تجمع چربی شکمی را نسبت به قد و وزن ارزیابی می‌کند.';
  static const bmrTitle = 'نرخ متابولیسم پایه (BMR)';
  static const bmrDesc =
      'انرژی مورد نیاز بدن در حالت استراحت برای حفظ عملکردهای حیاتی است.';
  static const bmrFootnote =
      'این مقدار تقریبی است و بر اساس سن، جنس، قد و وزن برآورد می‌شود.';
  static const tdeeTitle = 'مصرف انرژی روزانه کل (TDEE)';
  static const tdeeDesc =
      'کل انرژی مصرفی روزانه با درنظرگرفتن سطح فعالیت بدنی است.';
  static const hypertensionRiskDesc =
      'احتمال ابتلا به فشار خون بالا را بر اساس عوامل خطر برآورد می‌کند.';
  static const diabetesRiskDesc =
      'احتمال ابتلا به دیابت نوع ۲ را بر اساس عوامل خطر برآورد می‌کند.';
  static const wellnessScoreDesc =
      'امتیاز کلی تندرستی بر اساس اندازه‌گیری و پروفایل سلامت شما.';
  static const nafldRiskDesc =
      'سطح ریسک بیماری کبد چرب غیرالکلی بر اساس اندازه‌های بدنی.';

  // Risk form
  static const healthProfile = 'پروفایل سلامت';
  static const riskFactors = 'عوامل خطر';
  static const riskFactorsHint =
      'اطلاعات پایه الزامی است. کلسترول، HDL و سایر آزمایش‌ها اختیاری‌اند — '
      'اگر به‌خاطر ندارید خالی بگذارید؛ فقط شاخص‌های وابسته به آن‌ها محاسبه نمی‌شوند.';
  static const sectionBody = 'بدن (الزامی)';
  static const sectionBlood = 'فشار خون (الزامی)';
  static const sectionHistory = 'سابقه';
  static const sectionLifestyle = 'سبک زندگی';

  static const age = 'سن';
  static const gender = 'جنسیت';
  static const heightCm = 'قد (سانتی‌متر)';
  static const weightKg = 'وزن (کیلوگرم)';
  static const waistCm = 'دور کمر (سانتی‌متر)';
  static const neckCm = 'دور گردن (سانتی‌متر)';
  static const hipCm = 'دور باسن (سانتی‌متر)';
  static const cholesterol = 'کلسترول';
  static const hdl = 'HDL';
  static const triglyceride = 'تری‌گلیسیرید';
  static const fastingGlucose = 'قند ناشتا';
  static const sbpMmHg = 'فشار سیستولیک';
  static const dbpMmHg = 'فشار دیاستولیک';
  static const hypertensionTreatment = 'درمان فشار خون';
  static const familyDiabetes = 'دیابت در خانواده';
  static const parentalHypertension = 'فشار خون والدین';
  static const smoker = 'مصرف‌کننده دخانیات';
  static const diabetes = 'دیابت';
  static const historyHighGlucose = 'سابقه قند خون بالا';
  static const historyHypertension = 'سابقه فشار خون بالا';
  static const physicalActivity = 'فعالیت بدنی';
  static const race = 'نژاد';
  static const countryIso = 'کشور (کد ISO، مثل IR)';
  static const countryValidation = 'کد دو حرفی کشور را وارد کنید';
  static const vegetableFruitDiet = 'رژیم میوه و سبزیجات';
  static const computeHealthIndices = 'محاسبه شاخص‌ها و ریسک';

  // ShenRisk insurance assessment
  static const insuranceRiskAssessment = 'ارزیابی ریسک بیمه‌ای';
  static const insuranceRiskAssessmentDesc =
      'محاسبه‌شده با موتور ShenRisk پس از تکمیل پروفایل سلامت و ترکیب داده‌های اسکن چهره.';
  static const compositeInsuranceScore = 'نمره ریسک بیمه‌ای';
  static const underwritingDecision = 'تصمیم بیمه‌گری';
  static const premiumLoading = 'تعدیل حق‌بیمه';
  static const cardiovascularRisk10y = 'ریسک قلبی‌عروقی ۱۰ ساله';
  static const diabetesMetabolicRisk = 'ریسک دیابت و متابولیک';
  static const centralAdiposityOsa = 'چاقی مرکزی و آپنه خواب';
  static const autonomicLoad = 'تعادل اتونوم و بار فیزیولوژیک';
  static const tyGIndex = 'شاخص TyG';
  static const findriscScore = 'امتیاز FINDRISC';
  static const biologicalAgeEstimated = 'سن بیولوژیک تخمینی';
  static const criticalWarnings = 'هشدارهای حیاتی';
  static const riskReductionPlan = 'نقشه راه کاهش ریسک';
  static const currentScore = 'نمره فعلی';
  static const targetScore = 'نمره هدف';
  static const effectiveActions = 'اقدام‌های اثرگذار';
  static const deferredActions = 'اقدام‌های بنیادی با اثر تأخیری';
  static const maintainRiskTitle = 'وضعیت مطلوب — تمرکز روی حفظ سلامت';
  static const immutableFactors = 'فاکتورهای خط پایه';
  static const scoreDelta = 'کاهش امتیاز';
  static const basePremiumAnnual = 'حق‌بیمه پایه سالانه';
  static const currentPremium = 'حق‌بیمه فعلی';
  static const targetPremium = 'حق‌بیمه هدف';
  static const annualSavings = 'صرفه‌جویی سالانه';
  static const rial = 'ریال';
  static const mustBePositive = 'باید بزرگ‌تر از صفر باشد';
  static const required = 'الزامی';
  static const invalid = 'نامعتبر';
}
