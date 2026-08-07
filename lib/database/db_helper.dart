import 'dart:async';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/model/commercial/c_spinner_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/db_model/commercial/c_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_location_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_suburb_entity.dart';
import 'package:lf_survey/model/db_model/residential/city_entiy.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/image_entity.dart';
import 'package:lf_survey/model/db_model/residential/location_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_prj_img_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/db_model/residential/suburb_entity.dart';
import 'package:lf_survey/model/location_model.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/model/residential/archi_response.dart';
import 'package:lf_survey/model/residential/project_scheme_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static const _dbName = 'lf_servey.db';

  // Architect
  static const String architectEntity = "ArchitectEntity";

  // common table
  static const String costTypeEntity = "costTypeEntity";
  static const String imageEntity = "imageEntity";
  static const String locationEntity = "locationEntity";
  static const String remarkEntity = "RemarkEntity";

  static const String filterTB = "filterTB";
  static const String locationTB = "locationTB";

  /// Spinner Table Name
  static const String amenitiesEntity = "amenitiesEntity";
  static const String approvedBankEntity = "ApprovedBankEntity";
  static const String areaUnitEntity = "AreaEntity";
  static const String constProgressEntity = "ConstProgressEntity";
  static const String projectStatusEntity = "ProjectStatusEntity";
  static const String cityListEntity = "cityListEntity";
  static const String bookingStopRemarks = "BookingStopRemarks";
  static const String subProjectDeleteRemarks = "SubProjectDeleteRemarks";
  static const String schemes = "Schemes";
  static const String costIncluded = "CostIncluded";
  static const String flatTypeEntity = "FlatTypeEntity";
  static const String drinkingWater = "DrinkingWater";
  static const String projectScaleEntity = "projectScaleEntity";
  static const String modularKitchen = "ModularKitchen";
  static const String cityEntity = "cityEntity";
  static const String suburbEntity = "suburbEntity";

  /**  Residential Project Table */
  /// Project Table Name
  static const String projectEntity = "ProjectEntity";
  static const String projectSchemeEntity = "ProjectSchemeEntity";

  static const String newFlatEntity = "newFlatEntity";
  static const String newPrjImageEntity = "NewPrjImageEntity";
  static const String newProjectEntity = "NewProjectEntity";
  static const String newSubProjectEntity = "NewSubProjectEntity";

  // sub project Table name
  static const String subProjectEntity = "SubProjectEntity";
  static const String flatEntity = "FlatEntity";

  // Commercial Tables Name
  static const String cCityEntity = "cCityEntity";
  static const String cSuburbEntity = "cSuburbEntity";
  static const String cLocationEntity = "cLocationEntity";
  static const String cConstProgress = "cConstProgress";
  static const String cProjectStatusEntity = "cProjectStatusEntity";
  static const String cAreaEntity = "cAreaEntity";
  static const String cApproveBanks = "cApproveBanks";
  static const String cAmenties = "cAmenties";
  static const String cCityList = "cCity";
  static const String cOperationModelEntity = "cOperationModelEntity";
  static const String cBuildingType = "cBuildingTypeEntity";
  static const String cTenantMixEntity = "cTenantMixEntity";
  static const String cNewProjectEntity = "cNewProjectEntity";
  static const String cNewSubProjectEntity = "cNewSubProjectEntity";
  static const String cProjectEntity = "cProjectEntity";
  static const String cSubProjectEntity = "cSubProjectEntity";

  //***************************************** */
  // Pams Surveyor Tables Name
  static const String psProjectTB = "psProjectTB";
  static const String psSubProjectTB = "psSubProjectTB";
  static const String psLandDataTB = "psLandDataTB";
  static const String psImageDataTB = "psImageDataTB";

  // Construction Monitoring
  static const String cmBuildingTB = "cmBuildingTB";
  static const String cmWingTB = "cmWingTB";
  static const String cmNewWingTB = "cmNewWingTB";
  static const String cmProgressTB = "cmProgressTB";
  static const String cmWingSurveyTB = "cmWingSurveyTB";

  static const _dbVersion = 1;

  static final DBHelper instance = DBHelper._privateConstructor();
  static Database? _database;

  DBHelper._privateConstructor();

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // static Future<void> _onCreate(Database db, int version) async {}
  static Future<void> _onCreate(Database db, int version) async {
    /*********************** Common Table Residential ********************/
    await db.execute('''
    CREATE TABLE $filterTB(
       id INTEGER PRIMARY KEY,
       query TEXT,
       prjType TEXT
    )
  ''');

    // Cost Type Entity Table
    await db.execute('''
    CREATE TABLE $costTypeEntity(
      costType TEXT PRIMARY KEY
    )
  ''');
    // Image Entity Table
    //project id or sub projectid are stored in imageId
    await db.execute('''
    CREATE TABLE $imageEntity(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      RESIDENT INTEGER,
      COMMERICIAL INTEGER,
      imageId INTEGER,
      imageUri TEXT,
      dos TEXT,
      sync INTEGER,
      type INTEGER,
      img_lat TEXT,
      img_lon TEXT
    )
  ''');

    // Location Entity Table
    await db.execute('''
    CREATE TABLE $locationEntity(
      locationId INTEGER PRIMARY KEY,
      locationName TEXT,
      suburbId INTEGER,
      checked INTEGER
    )
  ''');

    // Operation Model Entity Table
    await db.execute('''
    CREATE TABLE $cOperationModelEntity(
      operatingModelId INTEGER PRIMARY KEY,
      operatingModel TEXT
    )
  ''');

    // Remarks Entity Table
    await db.execute('''
    CREATE TABLE $remarkEntity(
      remarksId INTEGER PRIMARY KEY,
      BOOKING_REMARKS INTEGER,
      DELETE_REMARKS INTEGER,
      remarks TEXT,
      type INTEGER
    )
  ''');

    // creating amenties Entity table
    await db.execute('''
    CREATE TABLE $amenitiesEntity(
      amenitiesId INTEGER PRIMARY KEY,
      amenities TEXT
    )
  ''');

    // Approve banks table
    await db.execute('''
    CREATE TABLE $approvedBankEntity(
      bankId INTEGER PRIMARY KEY,
      bankName TEXT
    )
  ''');

    // Creating Architect Entity Table
    await db.execute('''
    CREATE TABLE $architectEntity(
      architectId INTEGER PRIMARY KEY,
      architectName TEXT
    )
  ''');

    // area unit table
    await db.execute('''
    CREATE TABLE $areaUnitEntity(
      areaUnitId INTEGER PRIMARY KEY,
      areaUnitName TEXT,
      sqftConvert REAL
    )
  ''');

    // City entity table
    await db.execute('''
    CREATE TABLE $cityListEntity(
      city_id INTEGER PRIMARY KEY,
      city TEXT,
      area_type TEXT,
      area_type_freeze INTEGER
    )
  ''');

    // construction progress table
    await db.execute('''
    CREATE TABLE $constProgressEntity(
      constProgressId INTEGER PRIMARY KEY,
      constProgress TEXT
    )
  ''');

    // project status table
    await db.execute('''
    CREATE TABLE $projectStatusEntity(
      projectStatusId INTEGER PRIMARY KEY,
      projectStatus TEXT
    )
  ''');

    //booking stops remarks table
    await db.execute('''
    CREATE TABLE $bookingStopRemarks(
      remarksId INTEGER PRIMARY KEY,
      remarks TEXT
    )
  ''');

    //  sub project delete remarks table
    await db.execute('''
    CREATE TABLE $subProjectDeleteRemarks(
      remarksId INTEGER PRIMARY KEY,
      remarks TEXT
    )
  ''');

    // schemes table
    await db.execute('''
    CREATE TABLE $schemes(
      schemesId INTEGER PRIMARY KEY,
      schemesType TEXT,
      isOpenText INTEGER
    )
  ''');

    // cost include table
    await db.execute('''
    CREATE TABLE $costIncluded(
      costId INTEGER PRIMARY KEY,
      costType TEXT
    )
  ''');

    // flat type Table
    await db.execute('''
    CREATE TABLE $flatTypeEntity(
      flatId INTEGER PRIMARY KEY,
      flatType TEXT,
      flatTypeId INTEGER,
      min_value INTEGER,
      max_value INTEGER
    )
  ''');

    // drinking water table
    await db.execute('''
    CREATE TABLE $drinkingWater(
      drinkingWaterId INTEGER PRIMARY KEY,
      drinkingWater TEXT
    )
  ''');

    // project scale table
    await db.execute('''
    CREATE TABLE $projectScaleEntity(
      scale_id INTEGER PRIMARY KEY,
      project_scale TEXT
    )
  ''');

    // Modular Kitchen table
    await db.execute('''
    CREATE TABLE $modularKitchen(
      modularKitchenId TEXT,
      modularKitchen TEXT
    )
  ''');

    // creating project scheme table store the value which user store in it
    await db.execute('''
    CREATE TABLE $projectSchemeEntity(
      schemeId INTEGER PRIMARY KEY,
      projectId INTEGER,
      qtrId INTEGER,
      openText TEXT
    )
  ''');

    // City entity table
    await db.execute('''
    CREATE TABLE $cityEntity(
      cityId INTEGER PRIMARY KEY,
      cityName,
      checked INTEGER
    )
  ''');

    // create suburb Entity Table
    await db.execute('''
    CREATE TABLE $suburbEntity(
      suburbId INTEGER PRIMARY KEY,
      suburbName TEXT,
      cityId INTEGER
    )
  ''');

    // create Tenant MixEntity table
    await db.execute('''
    CREATE TABLE $cTenantMixEntity(
      tenantMixId INTEGER PRIMARY KEY,
      tenantMix TEXT
    )
  ''');

    // Create Project Entity Table
    await db.execute('''
      CREATE TABLE $projectEntity (
        projectId INTEGER PRIMARY KEY,
        dos TEXT,
        projectName TEXT,
        projectAddress TEXT,
        pxval REAL,
        pyval REAL,
        projectPhoneNo TEXT,
        projectMobileNo TEXT,
        builderId INTEGER,
        builderName TEXT,
        builderAddress TEXT,
        builderPhoneNo TEXT,
        builderMobileNo TEXT,
        roadName TEXT,
        locationId INTEGER,
        locationName TEXT,
        suburbId INTEGER,
        cityId INTEGER,
        city TEXT,
        reDevelopment INTEGER,
        reraNo TEXT,
        drinkingWater TEXT,
        totalWings INTEGER,
        marketableWings INTEGER,
        totalSupplyUnits INTEGER,
        landParcelSize REAL,
        landParcelSizeUnit INTEGER,
        syncGlobalStatus INTEGER,
        syncLocalStatus INTEGER,
        projectUnsold INTEGER,
        qtrId INTEGER,
        projectCosting TEXT,
        modularKitchenBrand TEXT,
        architectName TEXT,
        architectId INTEGER,
        IsWrongPXValPYVal INTEGER,
        rejectId INTEGER,
        fixedBy INTEGER,
        rejectedSurveyorId INTEGER,
        cinNo TEXT,
        SCHEME_OTHERS TEXT,
        telFlag INTEGER,
        userid INTEGER,
        syncCheckDate TEXT,
        rera_info TEXT,
        newProjectUpdate INTEGER,
        assignedNewPrj INTEGER
      );
    ''');

    // Create sub-project entity table
    await db.execute('''
      CREATE TABLE $subProjectEntity (
        subProjectId INTEGER PRIMARY KEY,
        dos TEXT,
        subProjectName TEXT,
        saleableRatepsf INTEGER,
        carpetRatepsf INTEGER,
        startDate TEXT,
        endDate TEXT,
        wings INTEGER,
        storey INTEGER,
        flatsPerFloor INTEGER,
        projectStatusId INTEGER,
        constructionProgressId INTEGER,
        floorSlab INTEGER,
        remarks TEXT,
        scr INTEGER,
        maintenancePersqft REAL,
        stiltPark TEXT,
        openPark TEXT,
        podium TEXT,
        doublePodium TEXT,
        basementPark TEXT,
        bookingStop INTEGER,
        floorRise INTEGER,
        deleteFlag INTEGER,
        hasVillas INTEGER,
        percVilaStarted TEXT,
        percVilaPiling TEXT,
        percVilaPlinth TEXT,
        percVilaFloorslab TEXT,
        percVilaInternalWork TEXT,
        percVilaExternal TEXT,
        percVilaComplete TEXT,
        syncGlobalStatus INTEGER,
        syncLocalStatus INTEGER,
        flatSoldCount INTEGER,
        projectId INTEGER,
        surveyDate TEXT,
        qtrId TEXT,
        rateType TEXT,
        isCarpetOrSaleableChoosen INTEGER,
        errMsg TEXT,
        flatgroupid INTEGER,
        assignedNewPrj INTEGER
      );
    ''');

    // Creating Tables of Flats Entity Table
    await db.execute('''
    CREATE TABLE $flatEntity (
      id TEXT PRIMARY KEY,
      flatId INTEGER,
      flatType TEXT,
      flatSold INTEGER,
      flatUnsold INTEGER,
      oldFlatSold INTEGER,
      flatSize TEXT,
      flatSizeCarpet TEXT,
      flatSizeAvg REAL,
      flatSizeCarpetAvg REAL,
      subProjectId INTEGER,
      projectId INTEGER,
      isSaleableEnable INTEGER,
      sizeType TEXT,
      dataFilled INTEGER
    );
  ''');

    // Project New Flat Entity Table
    await db.execute('''
    CREATE TABLE $newFlatEntity(
      newFlatId TEXT PRIMARY KEY,
      new_sub_project_id TEXT,
      flatTypeId INTEGER,
      flatType TEXT,
      flatSize TEXT,
      carpetSize TEXT,
      areaType TEXT,
      flatSold INTEGER,
      totalFlats INTEGER,
      createdDateTime TEXT,
      syncGlobalStatus INTEGER
    )
  ''');

    //New Project Image Entity Table
    await db.execute('''
    CREATE TABLE $newPrjImageEntity(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      prj_id TEXT,
      image_uri TEXT,
      img_lat REAL,
      img_lng REAL,
      img_loc_accuracy REAL,
      created_datetime TEXT,
      sync_status INTEGER
    )
  ''');

    // New Project Entity Table
    await db.execute('''
    CREATE TABLE $newProjectEntity(
      prjId TEXT PRIMARY KEY,
      prjName TEXT,
      prjAddr TEXT,
      lat REAL,
      lng REAL,
      rera_not_launched INTEGER,
      userId INTEGER,
      cityId INTEGER,
      builderName TEXT,
      architectName TEXT,
      mobileNo TEXT,
      prjAmenitiesIds TEXT,
      prjApprovedBanksIds TEXT,
      prjScaleId INTEGER,
      isLottery INTEGER,
      isRedevelopment INTEGER,
      createdDateTime TEXT,
      qtrId INTEGER,
      qtr TEXT,
      reraPrjType TEXT,
      reraNo TEXT,
      syncLocalStatus INTEGER,
      syncGlobalStatus INTEGER
    )
  ''');

    // New Sub-Project Entity Table
    await db.execute('''
    CREATE TABLE $newSubProjectEntity(
      subPrjid TEXT PRIMARY KEY,
      projectId INTEGER,
      newProjectId TEXT,
      qtrid INTEGER,
      qtr TEXT,
      subPrjName TEXT,
      storey INTEGER,
      scr INTEGER,
      maintenance REAL,
      flatsPerFloor INTEGER,
      flatGroup INTEGER,
      saleableLaunchPrice REAL,
      carpetLaunchPrice REAL,
      rate_type TEXT,
      launchDate TEXT,
      endDate TEXT,
      constructionProgressId INTEGER,
      constructionProgress TEXT,
      floorSlab INTEGER,
      reraNo TEXT,
      remarks TEXT,
      floorRise INTEGER,
      stilt_parking TEXT,
      open_parking TEXT,
      podium_parking TEXT,
      double_podium_parking TEXT,
      basement_parking TEXT,
      createdDateTime TEXT,
      syncLocalStatus INTEGER,
      syncGlobalStatus INTEGER,
      errMsg TEXT
    )
  ''');

    /** ********** Commercial projects Tables ************** */

    // Building Type Table
    await db.execute('''
    CREATE TABLE $cBuildingType(
      buildingTypeId INTEGER PRIMARY KEY,
      buildingType TEXT
    )
  ''');

    // Commercial Amenties Table
    await db.execute('''
    CREATE TABLE $cAmenties(
      amenitiesId INTEGER PRIMARY KEY,
      amenities TEXT
    )
  ''');

    // Commercial Approve Banks
    await db.execute('''
    CREATE TABLE $cApproveBanks(
      bankId INTEGER PRIMARY KEY,
      bankName TEXT
    )
  ''');
    // Commercial Area Table
    await db.execute('''
    CREATE TABLE $cAreaEntity(
      areaUnitId INTEGER PRIMARY KEY,
      areaUnitName TEXT,
      sqftConvert REAL
    )
  ''');

    // Commercial City Table
    await db.execute('''
    CREATE TABLE $cCityList(
      city_id INTEGER PRIMARY KEY,
      city TEXT,
      area_type TEXT
    )
  ''');

    // Commercial Constrcution Progess Table
    await db.execute('''
    CREATE TABLE $cConstProgress(
      constProgressId INTEGER PRIMARY KEY,
      constProgress TEXT
    )
  ''');

    // Comercial City Entity Table
    await db.execute('''
    CREATE TABLE $cCityEntity(
      cityId INTEGER PRIMARY KEY,
      cityName TEXT,
      checked INTEGER
    )
  ''');

    // Commercial Suburb Entity Table
    await db.execute('''
    CREATE TABLE $cSuburbEntity(
      suburbId INTEGER PRIMARY KEY,
      suburbName TEXT,
      cityId INTEGER
    )
  ''');

    // Commercial Location Entity Table
    await db.execute('''
    CREATE TABLE $cLocationEntity(
      locationId INTEGER PRIMARY KEY,
      locationName TEXT,
      suburbId INTEGER,
      checked INTEGER
    )
  ''');

    // Commercial New Project Entity Table
    await db.execute('''
    CREATE TABLE $cNewProjectEntity(
      prjId TEXT PRIMARY KEY,
      prjName TEXT,
      prjAddr TEXT,
      roadName TEXT,
      cityId INTEGER,
      builderName TEXT,
      architectName TEXT,
      lat REAL,
      lng REAL,
      mobile TEXT,
      amenitiesIds TEXT,
      approvedBankIds TEXT,
      operatingModelId INTEGER,
      buildingTypeId INTEGER,
      tenantMixId INTERGER,
      dos TEXT, 
      mobileCreatedDatetime TEXT,
      localSyncStatus INTEGER,
      globalSyncStatus INTEGER,
      errorMessage TEXT
    )
  ''');
    // Commercial New Sub-Project Entity
    await db.execute('''
    CREATE TABLE $cNewSubProjectEntity(
      subPrjId TEXT PRIMARY KEY,
      prjId TEXT,
      prjIdLF INTEGER,
      subPrjName TEXT,
      storey INTEGER,
      scr INTEGER,
      maintenance REAL,
      floorPlate INTEGER,
      carpetOrSaleable TEXT,
      leaseBareshell REAL,
      leaseWarmshell REAL,
      leaseFullyFurnished REAL,
      outrightBareshell REAL,
      outrightWarmshell REAL,
      outrightFullyFurnished REAL,
      launchDate TEXT,
      endDate TEXT,
      constructionStageId INTEGER,
      floorSlab INTEGER,
      totalSupply REAL,
      soldPercent REAL,
      unsoldPercent REAL,
      leasePercent REAL,
      vacantPercent REAL,
      reraNo TEXT,
      remark TEXT,
      dos TEXT,
      mobileCreatedDatetime TEXT,
      localSyncStatus INTEGER,
      globalSyncStatus INTEGER,
      errorMessage TEXT
    )
  ''');

    // Commercial Project Entity Table
    await db.execute('''
    CREATE TABLE $cProjectEntity(
      projectId INTEGER PRIMARY KEY,
      locationId INTEGER,
      suburbId INTEGER,
      cityId INTEGER,
      pxval REAL,
      pyval REAL,
      dos TEXT,
      projectName TEXT,
      projectAddress TEXT,
      projectPhoneNo TEXT,
      projectContactPerson TEXT,
      projectMobileNo TEXT,
      builderId INTEGER,
      builderName TEXT,
      builderAddress TEXT,
      builderContactPerson TEXT,
      builderPhoneNo TEXT,
      builderMobileNo TEXT,
      roadName TEXT,
      parkingOpen INTEGER,
      parkingStacked INETGER,
      parkingStilt INETGER,
      parkingBasement INETGER,
      parkingPodium INETGER,
      parkingRatio REAL,
      scr REAL,
      maintenancePerSqft REAL,
      propertyTax INTEGER,
      landParcelSizeUnit INTEGER,
      landParcelSize REAL,
      tenantMixId INTEGER,
      syncGlobalStatus INTEGER,
      syncLocalStatus INTEGER,
      rerano TEXT,
      telFlag INTEGER,
      userid INTEGER
    )
  ''');
    // Commercial Project Status Entity Table
    await db.execute('''
    CREATE TABLE $cProjectStatusEntity(
      projectStatusId INTEGER PRIMARY KEY,
      projectStatus TEXT
    )
  ''');

    // Commercial Subproject Entity Table
    await db.execute('''
    CREATE TABLE $cSubProjectEntity(
      subProjectId INTEGER PRIMARY KEY,
      dos TEXT,
      subProjectName TEXT,
      storeyBasement INTERGER,
      storeyPodium INTERGER,
      storeyService INTERGER,
      storeyHabitable INTERGER,
      constStartDate TEXT,
      constEndDate TEXT,
      marketingStartDate TEXT,
      marketingEndDate TEXT,
      constructionProgressId INTEGER,
      floorSlab INETEGRER,
      buildingTypeId INTEGER,
      operationModelId INTEGER,
      totalSupplySqft INTEGER,
      soldAreaSqft INTEGER,
      unsoldAreaSqft INTEGER,
      leasedOccupiedArea INTEGER,
      vacancyArea INTEGER,
      minFloorplate INTEGER,
      maxFloorplate INTEGER,
      orBareshell INTEGER,
      orWarmshell INTEGER,
      orFullyFurnished INTEGER,
      lrBareshell INTEGER,
      lrWarmshell INTEGER,
      lrFullyFurnished INTEGER,
      projectStatusId INTEGER,
      remarks TEXT,
      syncGlobalStatus INTEGER,
      syncLocalStatus INTEGER,
      projectId INTEGER
    )
  ''');

    //****************  Pams Surveyor Table Creation */
    await db.execute('''
    CREATE TABLE $psProjectTB(
      project_id INTEGER PRIMARY KEY,
      project_name TEXT,
      rera_reg_no TEXT,
      lfproject_id INTEGER,
      super_project_id INTEGER,
      project_addon_json TEXT,
      builder_group TEXT,
      spv_id INTEGER,
      lat REAL,
      lng REAL,
      location_id INTEGER,
      legal_address TEXT,
      construction_type_id INTEGER,
      construction_quality TEXT,
      geo_type TEXT,
      is_green INTEGER,
      legal_advisor_id INTEGER,
      ca_id INTEGER,
      has_solar INTEGER,
      has_rain_harvest INTEGER,
      has_sewage INTEGER,
      has_gen_backup INTEGER,
      parking_json_as_per_approved_plan TEXT,
      parking_json_as_per_sales_sheet TEXT,
      architect_id INTEGER,
      contractor_id INTEGER,
      project_building_name TEXT,
      project_address_road_name TEXT,
      project_address_sub_locality TEXT,
      project_address_nearby_landmark TEXT,
      project_address_city TEXT,
      project_address_district TEXT,
      project_address_state TEXT,
      project_address_pincode TEXT,
      confirmation_address TEXT,
      amenities_ids TEXT,
      is_it_the_tallest_building INTEGER,
      are_all_residents_celebrities INTEGER,
      are_all_units_large INTEGER,
      has_solar_power INTEGER,
      has_rainwater_harvesting INTEGER,
      has_sewage_treatment INTEGER,
      has_generator_backup INTEGER,
      ready_reckoner_value TEXT,
      rera_start_date TEXT,
      rera_completion_date TEXT,
      rera_extended_completion_date TEXT,
      rera_litigation_count TEXT,
      rera_litigation_details TEXT,
      rera_remarks TEXT,
      rera_name TEXT,
      district_name TEXT,
      taluka_name TEXT,
      village_name TEXT,
      zone_name TEXT,
      survey_number TEXT,
      apf_status INTEGER,
      cm_status INTEGER,
      allocation_id INTEGER,
      localSync INTEGER,
      globalSync INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE $psSubProjectTB(
      project_id INTEGER PRIMARY KEY,
      dos TEXT,
      wing_id INTEGER,
      wing_name TEXT,
      building_id INTEGER,
      carpet_rate TEXT,
      launch_date TEXT,
      scr_loading TEXT,
      club_charges TEXT,
      saleable_rate TEXT,
      number_of_slabs TEXT,
      possession_date TEXT,
      wing_addon_json TEXT,
      number_of_floors TEXT,
      average_floor_rise TEXT,
      maintenance_charges TEXT,
      stack_parking_charges TEXT,
      stilt_parking_charges TEXT,
      podium_parking_charges TEXT,
      average_parking_charges TEXT,
      basement_parking_charges TEXT,
      construction_progress_dos TEXT,
      mechanical_parking_charges TEXT,
      localSync INTEGER,
      globalSync INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE $psLandDataTB(
      project_id INTEGER PRIMERY KEY,
      project_land_id INTEGER,
      allocationId INTEGER,
      land_use TEXT,
      lat REAL,
      lng REAL,
      locality_class TEXT,
      land_situated_on TEXT,
      area_as_per_site TEXT,
      area_as_per_ownership_document TEXT,
      area_as_per_measurement_sheet TEXT,
      area_as_per_approved_plan TEXT,
      area_of_plot_deviation TEXT,
      permissible_fsi_bua_residential TEXT,
      permissible_fsi_bua_commercial TEXT,
      permissible_fsi_bua_others TEXT,
      permissible_fsi_bua_total TEXT,
      consumed_fsi_bua_residential TEXT,
      consumed_fsi_bua_commercial TEXT,
      consumed_fsi_bua_others TEXT,
      consumed_fsi_bua_total TEXT,
      build_up_area_remark TEXT,
      project_area_details_fsi_far_details TEXT,
      project_area_details_plot_fsi_far TEXT,
      project_area_details_premium_fsi_far TEXT,
      project_area_details_premium_tdr_fsi TEXT,
      project_area_details_premium_fungiable_fsi TEXT,
      project_area_details_fsi_under_regulation_1 TEXT,
      project_area_details_fsi_under_regulation_2 TEXT,
      project_area_details_total_fsi_far TEXT,
      width_of_accesss_road TEXT,
      type_of_access_road TEXT,
      east_as_per_site TEXT,
      east_as_per_document TEXT,
      east_as_per_rera TEXT,
      east_deviation TEXT,
      west_as_per_site TEXT,
      west_as_per_document TEXT,
      west_as_per_rera TEXT,
      west_deviation TEXT,
      north_as_per_site TEXT,
      north_as_per_document TEXT,
      north_as_per_rera TEXT,
      north_deviation TEXT,
      south_as_per_site TEXT,
      south_as_per_document TEXT,
      south_as_per_rera TEXT,
      south_deviation TEXT,
      civic_aminities_json TEXT,
      critical_parameters_seismic_zone TEXT,
      critical_parameters_flood_prone_area TEXT,
      critical_parameters_coastal_regulatory_zone TEXT,
      critical_parameters_zoning_as_per_development_plan TEXT,
      critical_parameters_falling_in_present TEXT,
      critical_parameters_property_within_30m_from_railway TEXT,
      critical_parameters_property_near_ht_lt_lines TEXT,
      critical_parameters_presence_of_nallah_water_body_nearby TEXT,
      critical_parameters_fsi_deviation TEXT,
      critical_parameters_vertical_deviation TEXT,
      critical_parameters_unit_deviation TEXT,
      critical_parameters_habitation TEXT,
      critical_parameters_remarks TEXT,
      critical_parameters_falling_in_reservation TEXT,
      construction_status TEXT,
      construction_material_status TEXT,
      labour_statuson_site TEXT,
      projectcfby_which_bank TEXT,
      project_homeloan_availble TEXT,
      visitCharges TEXT,
      revisitRemarks TEXT,
      globalSync INTEGER,
      localSync INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE $psImageDataTB (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      photo_id INTEGER,
      project_id INTEGER,
      buildingId INTEGER,
      wingId INTEGER,
      localBuildingId TEXT,
      localWingId TEXT,
      photo_type TEXT,
      photo_path TEXT,
      remarks TEXT,
      photo_lat REAL,
      photo_lng REAL,
      photo_loc_accuracy REAL,
      photo_created_date_time TEXT,
      imageCategory TEXT,
      sync INTEGER
    )
  ''');

    // Construction Monitoring Module Tables
    await db.execute('''
    CREATE TABLE $cmBuildingTB (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_id INTEGER,
      building_id INTEGER,
      building_name TEXT,
      createdBuildingId TEXT,
      errorMsg TEXT,
      sync INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE $cmWingTB (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      wing_id INTEGER,
      project_id INTEGER,
      wing_name TEXT,
      building_id INTEGER,
      building_name TEXT,
      dos TEXT,
      carpet_rate TEXT,
      launch_date TEXT,
      scr_loading TEXT,
      club_charges TEXT,
      saleable_rate TEXT,
      number_of_slabs TEXT,
      possession_date TEXT,
      wing_addon_json TEXT,
      number_of_floors TEXT,
      average_floor_rise TEXT,
      maintenance_charges TEXT,
      stack_parking_charges TEXT,
      stilt_parking_charges TEXT,
      podium_parking_charges TEXT,
      average_parking_charges TEXT,
      basement_parking_charges TEXT,
      construction_progress_dos TEXT,
      mechanical_parking_charges TEXT,
      createdBuildingId TEXT,
      createdWingId TEXT,
      errorMsg TEXT,
      submit_status INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE $cmWingSurveyTB(
      id INTEGER PRIMARY KEY,
      projectId INTEGER,
      wingId INTEGER,
      buildingId INTEGER,
      localBuildingId TEXT,
      localWingId TEXT,
      numberOfFloor TEXT,
      surveyDate TEXT,
      plinth TEXT,
      no_of_slabs_completed TEXT,
      brick_work TEXT,
      plastering_internal TEXT,
      plastering_external TEXT,
      flooring TEXT,
      electrict TEXT,
      plumbing TEXT,
      wood_work TEXT,
      painting TEXT,
      remarks TEXT,
      totalUnits INTEGER,
      soldUnits INTEGER,
      soldPercentage REAL,
      unsoldUnits INTEGER,
      unsoldPercentage REAL,
      saleableRate INTEGER,
      carpetRate INTEGER,
      globalSync INTEGER,
      localSync INTEGER
    )
  ''');

    await db.execute('''
    CREATE TABLE $locationTB(
      id INTEGER PRIMARY KEY,
      lat REAL,
      long REAL,
      accuracy REAL,
      timeStamp INTEGER,
      batteryPercentage INTEGER,
      mobileAppId INTEGER,
      userId INTEGER,
      isMock TEXT,
      provider TEXT
    )
  ''');
  }

  static Future<void> saveFilterQuery({required String filterQuery, bool isResidential = false}) async {
    final db = await database;
    await db.insert(
      filterTB,
      {'id': 1, 'query': filterQuery, 'prjType': isResidential ? "res" : "com"},
      conflictAlgorithm: ConflictAlgorithm.replace, // will update if exists
    );
  }

  static Future<Map<String, dynamic>?> getFilterQuery() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(filterTB, where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  static Future<void> clearFilterQuery() async {
    final db = await database;
    await db.delete(filterTB, where: 'id = ?', whereArgs: [1]);
  }

  static Future<void> insertList<T>(String tableName, List<T>? list, Map<String, dynamic> Function(T) toMap) async {
    if (list == null || list.isEmpty) return;

    final db = await database;

    Batch batch = db.batch(); // Use batch for faster insertion
    for (var item in list) {
      batch.insert(tableName, toMap(item), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // INSERT SPINNER DATA
  static Future<void> insertSpinnerData(SpinnerResponse response) async {
    final data = response.data;
    if (data == null) return;

    await insertList(constProgressEntity, data.constProgressList, (x) => x.toJson());
    await insertList(projectStatusEntity, data.projectStatusList, (x) => x.toJson());
    await insertList(areaUnitEntity, data.areaUnitList, (x) => x.toJson());
    await insertList(approvedBankEntity, data.approvedBankList, (x) => x.toJson());
    await insertList(amenitiesEntity, data.amenitiesList, (x) => x.toJson());
    await insertList(schemes, data.schemesList, (x) => x.toJson());
    await insertList(flatTypeEntity, data.flatTypeList, (x) => x.toJson());
    await insertList(drinkingWater, data.drinkingWaterList, (x) => x.toJson());
    await insertList(cityListEntity, data.cityList, (x) => x.toJson());
    await insertList(projectScaleEntity, data.projectScaleList, (x) => x.toJson());
    await insertList(modularKitchen, data.modularKitchenList, (x) => x.toJson());
    await insertList(costIncluded, data.costIncludedList, (x) => x.toJson());
    await insertList(bookingStopRemarks, data.bookingStopRemarksList, (x) => x.toJson());
    await insertList(subProjectDeleteRemarks, data.subProjectDeleteRemarksList, (x) => x.toJson());
  }

  // FETCH LIST DATA
  static Future<List<Map<String, dynamic>>> fetchTable(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  static Future<List<Map<String, dynamic>>> getConstProgress() => fetchTable(constProgressEntity);
  static Future<List<Map<String, dynamic>>> getProjectStatus() => fetchTable(projectStatusEntity);
  static Future<List<Map<String, dynamic>>> getAreaUnit() => fetchTable(areaUnitEntity);
  static Future<List<Map<String, dynamic>>> getApprovedBank() => fetchTable(approvedBankEntity);
  static Future<List<Map<String, dynamic>>> getAmenities() => fetchTable(amenitiesEntity);
  static Future<List<Map<String, dynamic>>> getSchemes() => fetchTable(schemes);
  static Future<List<Map<String, dynamic>>> getFlatType() => fetchTable(flatTypeEntity);
  static Future<List<Map<String, dynamic>>> getDrinkingWater() => fetchTable(drinkingWater);
  static Future<List<Map<String, dynamic>>> getCity() => fetchTable(cityListEntity);
  static Future<List<Map<String, dynamic>>> getProjectScale() => fetchTable(projectScaleEntity);
  static Future<List<Map<String, dynamic>>> getModularKitchen() => fetchTable(modularKitchen);
  static Future<List<Map<String, dynamic>>> getCostIncluded() => fetchTable(costIncluded);
  static Future<List<Map<String, dynamic>>> getBookingStopRemarks() => fetchTable(bookingStopRemarks);
  static Future<List<Map<String, dynamic>>> getSubProjectDeleteRemarks() => fetchTable(subProjectDeleteRemarks);

  // Insert Project Data Into the table
  static Future<void> insertProjects(List<ProjectEntity> projectsData) async {
    final userId = await StorageFunction.readIntData(StorageKey.userId);
    final db = await database;
    final batch = db.batch();
    if (projectsData.isEmpty) return;
    for (var project in projectsData) {
      project.userId = userId;
      batch.insert(projectEntity, project.toPrjDb(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // update project data
  static Future<int> updateProject(ProjectEntity model) async {
    final db = await database;
    return db.update(projectEntity, model.toPrjDb(), where: "projectId = ?", whereArgs: [model.projectId]);
  }

  // Fetch Project All Data
  static Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    return await db.query(projectEntity);
  }

  // Fetch Unsync Project All Data
  static Future<List<Map<String, dynamic>>> getUnsyncProjects() async {
    final db = await database;
    return await db.query(
      projectEntity,
      where: 'syncGlobalStatus = ? AND syncLocalStatus = ?',
      whereArgs: [0, 1],
      // limit: 5,
    );
  }

  // Fetch Single Project Data
  static Future<Map<String, dynamic>?> getSingleProject({required int projectId}) async {
    final db = await database;
    final result = await db.query(projectEntity, where: 'projectId = ?', whereArgs: [projectId], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // Fetch Single Unsync Project Data
  static Future<Map<String, dynamic>?> getSingleUnsyncProject({required int projectId}) async {
    final db = await database;
    final result = await db.query(
      projectEntity,
      where: 'projectId = ? AND syncGlobalStatus = ? AND syncLocalStatus = ?',
      whereArgs: [projectId, 0, 1],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Delete Single Project Data
  static Future<int> deleteProjectEntityById({required int projectId}) async {
    final db = await database;
    return await db.delete(projectEntity, where: 'projectId = ?', whereArgs: [projectId]);
  }

  // insert Sub-Project Entity
  static Future<int> insertSprjEntity(SubProjectEntity subPrj) async {
    final db = await database;
    return await db.insert(subProjectEntity, subPrj.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // insert Sub-Project Entity bulk
  static Future<void> insertSubProjectsBulk(List<SubProjectEntity> list) async {
    final db = await database;
    final batch = db.batch();
    for (var item in list) {
      batch.insert(subProjectEntity, item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Update Sub-Project Entity
  static Future<int> updateSprjEntity(SubProjectEntity subPrj) async {
    final db = await database;
    if (subPrj.subProjectId == null) {
      throw Exception('Cannot update a record without subProjectId');
    }
    return await db.update(
      subProjectEntity,
      subPrj.toMap(),
      where: 'subProjectId = ?',
      whereArgs: [subPrj.subProjectId],
    );
  }

  // Fetch All Sub Sroject Entities By Project Id
  static Future<List<Map<String, dynamic>>> fetchAllSprjEntityByPrjId({required int projectId}) async {
    final db = await database;
    return await db.query(subProjectEntity, where: 'projectId = ?', whereArgs: [projectId]);
  }

  // Fetch All Sub Sroject Entities
  static Future<List<Map<String, dynamic>>> getAllSprjEntity() async {
    final db = await database;
    return await db.query(subProjectEntity);
  }

  // Fetch 5 Unsync Sub Sroject Entities
  static Future<List<Map<String, dynamic>>> getUnSyncSprjEntities() async {
    final db = await database;
    return await db.query(subProjectEntity, where: 'syncGlobalStatus = ?', whereArgs: [0], limit: 5);
  }

  // Fetch single sub project entity
  static Future<Map<String, dynamic>?> getSprjEntity({required int projectId, required int subPrjId}) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      subProjectEntity,
      where: 'projectId = ? AND subProjectId = ?',
      whereArgs: [projectId, subPrjId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<int> deleteSubprojectEntity({required int subProjectId}) async {
    final db = await database;
    final result = await db.delete(subProjectEntity, where: 'subProjectId = ?', whereArgs: [subProjectId]);
    return result;
  }

  // Insert Flat Entity
  static Future<int> insertFlat(FlatEntity flatData) async {
    final db = await database;
    return await db.insert(flatEntity, flatData.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert Flat Entity in Bulk
  static Future<void> insertFlatsBulk(List<FlatEntity> flats) async {
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var flat in flats) {
        batch.insert(flatEntity, flat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    });
  }

  // Update Flat Entity
  static Future<int> updateFlat({required FlatEntity flatData}) async {
    final db = await database;
    return await db.update(
      flatEntity,
      flatData.toMap(),
      where: 'id = ?',
      whereArgs: [flatData.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch All Flat Entity By ProjectId and SubProjectId
  static Future<List<Map<String, dynamic>>> getFlats({required int projectId, required int subProjectId}) async {
    final db = await database;
    return await db.query(
      flatEntity,
      where: "projectId = ? AND subProjectId = ?",
      whereArgs: [projectId, subProjectId],
    );
  }

  // Fetch total unsold Flat Entity By ProjectId
  static Future<int> getTotalUnsoldFlats({required int projectId}) async {
    final db = await database;
    final result = await db.rawQuery("SELECT SUM(flatUnsold) as total FROM $flatEntity WHERE projectId = ?", [
      projectId,
    ]);
    return result.first["total"] != null ? result.first["total"] as int : 0;
  }

  static Future<Map<int, int>> getUnsoldFlatsForAllProjects() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT projectId, SUM(flatUnsold) as totalUnsold
    FROM $flatEntity
    GROUP BY projectId
  ''');
    Map<int, int> projectWise = {};
    for (var row in result) {
      int projectId = row['projectId'] as int;
      int totalSold = row['totalUnsold'] != null ? row['totalUnsold'] as int : 0;
      projectWise[projectId] = totalSold;
    }
    return projectWise;
  }

  // Fetch All Flat Entity
  static Future<List<FlatEntity>> getAllFlats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(flatEntity);
    return result.map((e) => FlatEntity.fromJson(e)).toList();
  }

  // Delete Flats By sub-project id
  static Future<int> deleteFlat({required int subProjectId}) async {
    final db = await database;
    final result = await db.delete(flatEntity, where: 'subProjectId = ?', whereArgs: [subProjectId]);
    return result;
  }

  // Instert Projects Scheme
  static Future<void> insertProjectScheme(List<ProjectSchemeEntity> projectScheme) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var scheme in projectScheme) {
        batch.insert(projectSchemeEntity, scheme.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception(e);
    }
  }

  // delete the schemes
  static deletePrjScheme(List<ProjectSchemeEntity> projectScheme) async {
    try {
      final db = await database;
      Batch batch = db.batch();
      for (var scheme in projectScheme) {
        batch.delete(projectSchemeEntity, where: "schemeId = ?", whereArgs: [scheme.schemeId]);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception(e);
    }
  }

  // fetch All project schemes for specific project
  static Future<List<Map<String, dynamic>>> getAllProjectsSchemes({required int projectId}) async {
    final db = await database;
    return await db.query(projectSchemeEntity, where: "projectId = ?", whereArgs: [projectId]);
  }

  // insert into architect table
  static Future<void> insertArchi(List<ArchitectDataum> archiList) async {
    final db = await database;
    Batch batch = db.batch();
    for (var archi in archiList) {
      batch.insert(architectEntity, archi.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // fetch all architects
  static Future<List<Map<String, dynamic>>> getArchitects() async {
    final db = await database;
    return await db.query(architectEntity);
  }

  /// INSERT into  Image Entity table
  static Future<int> insertImgEntity(ImageEntity model) async {
    final db = await database;
    return await db.insert(imageEntity, model.toImDb(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Fetch All Images from image entity table
  static Future<List<ImageEntity>> fetcAllImgEntity({required int resident, required int commercial}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      imageEntity,
      where: 'RESIDENT = ? AND COMMERICIAL = ?',
      whereArgs: [resident, commercial],
    );
    return maps.map((map) => ImageEntity.fromJson(map)).toList();
  }

  /// Fetch All Unsync Images from image entity table
  static Future<List<ImageEntity>> fetchUnSyncImgEntity() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(imageEntity, where: "sync = ?", whereArgs: [0]);
    return maps.map((map) => ImageEntity.fromJson(map)).toList();
  }

  /// Fetch All Images from image entity table for specific project or sub project
  static Future<List<ImageEntity>> fetcImgEntity({required imageId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(imageEntity, where: 'imageId = ?', whereArgs: [imageId]);
    return maps.map((map) => ImageEntity.fromJson(map)).toList();
  }

  /// READ Single Image Entity
  static Future<ImageEntity?> fetcSingleImgEntity({required int id}) async {
    final db = await database;
    final maps = await db.query(imageEntity, where: 'imageId = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return ImageEntity.fromJson(maps.first);
    }
    return null;
  }

  /// UPDATE Image Entity
  static Future<int> updateImgEntity(ImageEntity model) async {
    final db = await database;
    return await db.update(imageEntity, model.toImDb(), where: 'id = ?', whereArgs: [model.id]);
  }

  /// UPDATE Image Entity Using Image Path
  static Future<int> updateByImgPath(ImageEntity model) async {
    final db = await database;
    return await db.update(imageEntity, model.toImDb(), where: 'imageUri = ?', whereArgs: [model.imageUri]);
  }

  /// DELETE Image Entity
  static Future<int> deleteImgEntity({required int id}) async {
    final db = await database;
    return await db.delete(imageEntity, where: 'id = ?', whereArgs: [id]);
  }

  // insert new project entity
  static Future<int> insertNewProject(NewProjectEntity project) async {
    final db = await database;
    return await db.insert(
      newProjectEntity,
      project.toNewProjectEntityMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch All New Project Entity
  static Future<List<NewProjectEntity>> fetchAllNewProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(newProjectEntity);
    return result.map((map) => NewProjectEntity.fromJson(map)).toList();
  }

  // Fetch All Unsync New Project Entity
  static Future<List<NewProjectEntity>> fetchAllUnsyncNewProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      newProjectEntity,
      where: 'syncGlobalStatus = ?',
      whereArgs: [0],
    );
    return result.map((map) => NewProjectEntity.fromJson(map)).toList();
  }

  // Fetch Single New Project Entity
  static Future<NewProjectEntity?> fetchSingleNewPrjById(String prjId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      newProjectEntity,
      where: 'prjId = ?',
      whereArgs: [prjId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return NewProjectEntity.fromJson(result.first);
    }
    return null;
  }

  // Update New Project Entity
  static Future<int> updateNewProject(NewProjectEntity project) async {
    final db = await database;
    return await db.update(
      newProjectEntity,
      project.toNewProjectEntityMap(),
      where: 'prjId = ?',
      whereArgs: [project.prjId],
    );
  }

  // Delete New Project Entity
  static Future<int> deleteNewProject(String prjId) async {
    final db = await database;
    return await db.delete(newProjectEntity, where: 'prjId = ?', whereArgs: [prjId]);
  }

  // Insert New Sub Project Entity
  static Future<int> insertNewSubProject(NewSubProjectEntity data) async {
    final db = await database;
    return await db.insert(
      newSubProjectEntity,
      data.toNewSubPrjentityMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch All New Sub Project Entity
  static Future<List<NewSubProjectEntity>> getAllNewSubProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(newSubProjectEntity);
    return maps.map((e) => NewSubProjectEntity.fromJson(e)).toList();
  }

  // Fetch All New Sub Project Entity By Project Id
  static Future<List<NewSubProjectEntity>> getAllNewSubProjectByPrjId({required int projectId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      newSubProjectEntity,
      where: "projectId = ?",
      whereArgs: [projectId],
    );
    return maps.map((e) => NewSubProjectEntity.fromJson(e)).toList();
  }

  // Fetch All New Sub Project Entity By Project Id
  static Future<List<NewSubProjectEntity>> getAllNewSubProjectByNewPrjId({required String newPrjId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      newSubProjectEntity,
      where: "newProjectId = ?",
      whereArgs: [newPrjId],
    );
    return maps.map((e) => NewSubProjectEntity.fromJson(e)).toList();
  }

  // Fetch Unsync New Sub Project Entity By Project Id
  static Future<List<NewSubProjectEntity>> getAllUnsyncNewSubProjectById({String? subProjectId}) async {
    final db = await database;
    late List<Map<String, dynamic>> maps;
    if (subProjectId == null || subProjectId == '0' || subProjectId.isEmpty) {
      maps = await db.query(newSubProjectEntity, where: "syncGlobalStatus = ?", whereArgs: [0], limit: 5);
    } else {
      maps = await db.query(
        newSubProjectEntity,
        where: "subPrjid = ? AND syncGlobalStatus = ?",
        whereArgs: [subProjectId, 0],
        limit: 5,
      );
    }
    return maps.map((e) => NewSubProjectEntity.fromJson(e)).toList();
  }

  // Fetch Single New Sub Project Entity
  static Future<NewSubProjectEntity?> getSubProjectById({required String subPrjid}) async {
    final db = await database;
    final result = await db.query(newSubProjectEntity, where: 'subPrjid = ?', whereArgs: [subPrjid]);
    if (result.isNotEmpty) {
      return NewSubProjectEntity.fromJson(result.first);
    }
    return null;
  }

  // Update New Sub Project entity
  static Future<int> updateNewSubProjectEntity(NewSubProjectEntity data) async {
    final db = await database;
    return await db.update(
      newSubProjectEntity,
      data.toNewSubPrjentityMap(),
      where: 'subPrjid = ?',
      whereArgs: [data.subPrjid],
    );
  }

  // Delete New Sub Project Entity
  static Future<int> deleteNewSubProjectEntity(String subPrjid) async {
    final db = await database;
    return await db.delete(newSubProjectEntity, where: 'subPrjid = ?', whereArgs: [subPrjid]);
  }

  // New Flat Entity insert
  static Future<int> insertNewFlatEntity(NewFlatEntity flatData) async {
    final db = await database;
    return await db.insert(newFlatEntity, flatData.toNewFlatEntityMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get All Flat Entity
  static Future<List<NewFlatEntity>> fetchAllNewFlats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(newFlatEntity);
    return result.map((e) => NewFlatEntity.fromJson(e)).toList();
  }

  // Get All Flat Entity By sub project id
  static Future<List<NewFlatEntity>> fetchAllNewFlatsBySubPrjId(String subPrj) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      newFlatEntity,
      where: "new_sub_project_id = ?",
      whereArgs: [subPrj],
    );
    return result.map((e) => NewFlatEntity.fromJson(e)).toList();
  }

  // Get New Flat Entity By Id
  static Future<NewFlatEntity?> getNewFlatEntityById(String id) async {
    final db = await database;
    final result = await db.query('newFlatEntity', where: 'newFlatId = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return NewFlatEntity.fromJson(result.first);
    }
    return null;
  }

  // Update New Flat Entity
  static Future<int> updateNewFlatEntity(NewFlatEntity flat) async {
    final db = await database;
    return await db.update(
      newFlatEntity,
      flat.toNewFlatEntityMap(),
      where: 'newFlatId = ?',
      whereArgs: [flat.newFlatId],
    );
  }

  // Delete New Flat Entity
  static Future<int> deleteNewFlatEntity(String id) async {
    final db = await database;
    return await db.delete(newFlatEntity, where: 'newFlatId = ?', whereArgs: [id]);
  }

  // Insert New Project Image Entity
  static Future<int> insertNewPrjImageEntity(NewPrjImageEntity img) async {
    final db = await database;
    return db.insert(newPrjImageEntity, img.toNewPrjImgMap());
  }

  // Fetch All  New Project Image Entity
  static Future<List<NewPrjImageEntity>> fetchAllNewImgPrjEntity() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(newPrjImageEntity);
    return maps.map((map) => NewPrjImageEntity.fromJson(map)).toList();
  }

  // Fetch New Project Image Entity By Project Id
  static Future<List<NewPrjImageEntity>> fetchNewImgPrjEntityByPrjId(String prjId) async {
    final db = await database;
    final maps = await db.query(newPrjImageEntity, where: 'prj_id = ?', whereArgs: [prjId]);
    return maps.map((e) => NewPrjImageEntity.fromJson(e)).toList();
  }

  // Fetch single New Project Image Entity by Project Id
  static Future<NewPrjImageEntity?> singleNewImgPrjEntityByPrjId({
    required String prjId,
    required String imgUri,
  }) async {
    final db = await database;
    final maps = await db.query(
      newPrjImageEntity,
      where: 'prj_id = ? AND image_uri = ?',
      whereArgs: [prjId, imgUri],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return NewPrjImageEntity.fromJson(maps.first);
    }

    return null;
  }

  // Fetch Unsync New Project Image Entity By Project Id
  static Future<List<NewPrjImageEntity>> getUnsyncedNewImgPrjEntity(String prjId) async {
    final db = await database;
    final maps = await db.query(newPrjImageEntity, where: 'prj_id = ? AND sync_status = ?', whereArgs: [prjId, 0]);
    return maps.map((e) => NewPrjImageEntity.fromJson(e)).toList();
  }

  // Fetch Upadate New Project Image Entity By Id
  static Future<int> updateNewImgPrjEntity(NewPrjImageEntity image) async {
    final db = await database;
    return await db.update(newPrjImageEntity, image.toNewPrjImgMap(), where: 'id = ?', whereArgs: [image.id]);
  }

  // Delete New Project Image Entity By Id
  static Future<int> deleteNewImgPrjEntity(int id) async {
    final db = await database;
    return await db.delete(newPrjImageEntity, where: 'id = ?', whereArgs: [id]);
  }

  // Insert All City Entity
  static Future<int> insertCityEntity(CityEntity city) async {
    final db = await database;
    return await db.insert(cityEntity, city.toCityEntityMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Read All City Entity
  static Future<List<CityEntity>> fetchAllCitiesEntity() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(cityEntity);

    return maps.map((e) => CityEntity.fromMap(e)).toList();
  }

  // Update City Entity
  static Future<int> updateCityEntity(CityEntity city) async {
    final db = await database;
    return await db.update(cityEntity, city.toCityEntityMap(), where: 'cityId = ?', whereArgs: [city.cityId]);
  }

  // Delete City Entity
  static Future<int> deleteCityEntity(int cityId) async {
    final db = await database;
    return await db.delete(cityEntity, where: 'cityId = ?', whereArgs: [cityId]);
  }

  // Insert the Suburb Entity
  static Future<int> insertSuburbEntity(SuburbEntity suburb) async {
    final db = await database;
    return await db.insert(suburbEntity, suburb.toSuburbEntityMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Read All  the Suburb Entity
  static Future<List<SuburbEntity>> fetchAllSuburbsEntity() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(suburbEntity);

    return maps.map((e) => SuburbEntity.fromJson(e)).toList();
  }

  // READ all the Suburb Entity (by cityId)
  static Future<List<SuburbEntity>> fetchSuburbsByCityId(int cityId) async {
    final db = await database;
    final maps = await db.query(suburbEntity, where: 'cityId = ?', whereArgs: [cityId]);

    return maps.map((e) => SuburbEntity.fromJson(e)).toList();
  }

  // UPDATE the Suburb Entity
  static Future<int> updateSuburbEntity(SuburbEntity suburb) async {
    final db = await database;
    return await db.update(
      suburbEntity,
      suburb.toSuburbEntityMap(),
      where: 'suburbId = ?',
      whereArgs: [suburb.suburbId],
    );
  }

  // DELETE the Suburb Entity
  static Future<int> deleteSuburbEntity(int suburbId) async {
    final db = await database;
    return await db.delete(suburbEntity, where: 'suburbId = ?', whereArgs: [suburbId]);
  }

  // Insert Location Entity
  static Future<int> insertLocationEntity(LocationEntity location) async {
    final db = await database;
    return await db.insert(
      locationEntity,
      location.toLocationEntityMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read All Location Entity
  static Future<List<LocationEntity>> fetchAllLocationsEntity() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(locationEntity);

    return maps.map((e) => LocationEntity.fromJson(e)).toList();
  }

  // Read All Location Entity By Suburb Id
  static Future<List<LocationEntity>> fetchLocationsBySuburbId(int suburbId) async {
    final db = await database;
    final maps = await db.query(locationEntity, where: 'suburbId = ?', whereArgs: [suburbId]);
    return maps.map((e) => LocationEntity.fromJson(e)).toList();
  }

  // Update Location Entity
  static Future<int> updateLocationEntity(LocationEntity location) async {
    final db = await database;
    return await db.update(
      locationEntity,
      location.toLocationEntityMap(),
      where: 'locationId = ?',
      whereArgs: [location.locationId],
    );
  }

  // DELETE Location Entity
  static Future<int> deleteLocationEntity(int locationId) async {
    final db = await database;
    return await db.delete(locationEntity, where: 'locationId = ?', whereArgs: [locationId]);
  }

  static Future<void> clearAllData() async {
    final db = await database;
    final batch = db.batch();
    batch.delete(filterTB);
    batch.delete(amenitiesEntity);
    batch.delete(approvedBankEntity);
    batch.delete(architectEntity);
    batch.delete(areaUnitEntity);
    batch.delete(cityListEntity);
    batch.delete(cityEntity);
    batch.delete(constProgressEntity);
    batch.delete(projectStatusEntity);
    batch.delete(bookingStopRemarks);
    batch.delete(subProjectDeleteRemarks);
    batch.delete(schemes);
    batch.delete(costIncluded);
    batch.delete(flatTypeEntity);
    batch.delete(drinkingWater);
    batch.delete(projectScaleEntity);
    batch.delete(modularKitchen);

    batch.delete(projectEntity);
    batch.delete(projectSchemeEntity);
    batch.delete(subProjectEntity);
    batch.delete(flatEntity);
    batch.delete(newFlatEntity);
    batch.delete(newPrjImageEntity);
    batch.delete(newProjectEntity);
    batch.delete(newSubProjectEntity);

    batch.delete(suburbEntity);

    // Common tables
    batch.delete(costTypeEntity);
    batch.delete(imageEntity);
    batch.delete(locationEntity);
    batch.delete(remarkEntity);

    await batch.commit(noResult: true);
  }

  // PAMS Surveyor  Module

  // Project Section
  static Future<int> insertPsProject(PsPrjDatum psPrjDatum) async {
    final db = await database;
    return await db.insert(psProjectTB, psPrjDatum.toPsPrjDB(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<PsPrjDatum>> getAllPsProjects() async {
    final db = await database;
    final response = await db.query(psProjectTB);
    return response.map((e) => PsPrjDatum.fromJson(e)).toList();
  }

  static Future<PsPrjDatum?> getProjectById(int projectId) async {
    final db = await database;
    final result = await db.query(psProjectTB, where: 'project_id = ?', whereArgs: [projectId]);
    return result.isNotEmpty ? PsPrjDatum.fromJson(result.first) : null;
  }

  static Future<int> updatePsProject({required int projectId, required PsPrjDatum updatedData}) async {
    final db = await database;
    return await db.update(
      psProjectTB,
      updatedData.toPsPrjDB(),
      where: 'project_id = ?',
      whereArgs: [projectId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deletePsProject(int projectId) async {
    final db = await database;
    return await db.delete(psProjectTB, where: 'project_id = ?', whereArgs: [projectId]);
  }

  static Future<int> insertPsImage({required PsPhotoDatum image}) async {
    try {
      final db = await database;
      return await db.insert(psImageDataTB, image.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllPsImage() async {
    try {
      final db = await database;
      final response = await db.query(psImageDataTB, where: 'imageCategory = ?', whereArgs: ["pti"]);
      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllPsUnSyncImage() async {
    try {
      final db = await database;
      final response = await db.query(psImageDataTB, where: "sync = ? AND imageCategory = ?", whereArgs: [0, "pti"]);
      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllPsUnSyncImgByPrjId({required int projectId, required String imgPath}) async {
    try {
      final db = await database;
      final response = await db.query(
        psImageDataTB,
        where: "sync = ? AND project_id = ? AND photo_path = ? AND imageCategory = ?",
        whereArgs: [0, projectId, imgPath, "pti"],
      );
      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllPsImageByPrjId({required int projectId}) async {
    try {
      final db = await database;
      final response = await db.query(
        psImageDataTB,
        where: 'project_id = ? AND imageCategory = ?',
        whereArgs: [projectId, "pti"],
      );
      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllCmUnSyncImgByWingId({
    required int projectId,
    required int wingId,
    String? localWingId,
    required String imgPath,
  }) async {
    try {
      final db = await database;

      String where = '''
      sync = ? AND
      project_id = ? AND
      photo_path = ? AND
      imageCategory = ?
    ''';

      List<dynamic> whereArgs = [0, projectId, imgPath, 'cm'];

      if (localWingId != null && localWingId.isNotEmpty) {
        where += ' AND (wingId = ? OR localWingId = ?)';
        whereArgs.addAll([wingId, localWingId]);
      } else {
        where += ' AND wingId = ?';
        whereArgs.add(wingId);
      }

      final response = await db.query(psImageDataTB, where: where, whereArgs: whereArgs);

      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getCmUnSyncImagesByPrjId({required int projectId}) async {
    try {
      final db = await database;
      final response = await db.query(
        psImageDataTB,
        where: '''
      sync = ? AND 
      project_id = ?
    ''',
        whereArgs: [0, projectId],
      );
      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllCmUnSyncImage() async {
    try {
      final db = await database;
      final response = await db.query(psImageDataTB, where: "sync = ? AND imageCategory = ?", whereArgs: [0, "cm"]);
      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllCmImageByPrjIdAndWingId({
    required int projectId,
    int? wingId,
    String? localWingId,
  }) async {
    try {
      final db = await database;

      String where = 'project_id = ? AND imageCategory = ?';
      List<dynamic> whereArgs = [projectId, 'cm'];

      if (wingId != null && localWingId != null && wingId != 0 && localWingId != "") {
        where += ' AND (wingId = ? OR localWingId = ?)';
        whereArgs.addAll([wingId, localWingId]);
      } else if (wingId != null && wingId != 0) {
        where += ' AND wingId = ?';
        whereArgs.add(wingId);
      } else if (localWingId != null && localWingId != "") {
        where += ' AND localWingId = ?';
        whereArgs.add(localWingId);
      }

      final response = await db.query(psImageDataTB, where: where, whereArgs: whereArgs);

      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsPhotoDatum>> getAllCmImageByPrjId({required int projectId}) async {
    try {
      final db = await database;
      final response = await db.query(
        psImageDataTB,
        where: 'project_id = ? AND imageCategory = ? ',
        whereArgs: [projectId, "cm"],
      );
      return response.map((e) => PsPhotoDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> updatePsImage({required PsPhotoDatum image}) async {
    try {
      final db = await database;
      return await db.update(
        psImageDataTB,
        image.toJson(),
        where: 'project_id = ? AND id = ?',
        whereArgs: [image.projectId, image.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updatePsMultiImages({required List<PsPhotoDatum> images}) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (final image in images) {
        batch.update(
          psImageDataTB,
          image.toJson(),
          where: 'project_id = ? AND id = ?',
          whereArgs: [image.projectId, image.id],
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> deletePsImageById({required int imgId}) async {
    try {
      final db = await database;
      return await db.delete(psImageDataTB, where: 'id = ?', whereArgs: [imgId]);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> insertPsLandInfo({required PsLandDatum landData}) async {
    try {
      final db = await database;
      return await db.insert(psLandDataTB, landData.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> updatePsLandInfo({required PsLandDatum landData}) async {
    try {
      final db = await database;
      return await db.update(
        psLandDataTB,
        landData.toJson(),
        // where: 'project_id = ? AND project_land_id = ?',
        // whereArgs: [landData.projectId, landData.projectLandId],
        where: 'project_id = ? ',
        whereArgs: [landData.projectId],
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsLandDatum>> getPsLandInfo({required int projectId}) async {
    try {
      final db = await database;
      final response = await db.query(psLandDataTB, where: "project_id = ?", whereArgs: [projectId]);
      return response.map((e) => PsLandDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsLandDatum>> getUnsyncPsLandInfo({required int projectId}) async {
    try {
      final db = await database;
      final response = await db.query(
        psLandDataTB,
        where: "project_id = ? AND globalSync = ? AND localSync = ?",
        whereArgs: [projectId, 0, 1],
      );
      return response.map((e) => PsLandDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsLandDatum>> getAllUnsyncPsLandInfo() async {
    try {
      final db = await database;
      final response = await db.query(psLandDataTB, where: "globalSync = ?", whereArgs: [0]);
      return response.map((e) => PsLandDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsLandDatum>> getUnsyncPsLandInfoById({required int projectId}) async {
    try {
      final db = await database;
      final response = await db.query(
        psLandDataTB,
        where: "project_id = ? AND globalSync = ?",
        whereArgs: [projectId, 0],
      );
      return response.map((e) => PsLandDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PsLandDatum>> getAllPsLandInfo() async {
    try {
      final db = await database;
      final response = await db.query(psLandDataTB);
      return response.map((e) => PsLandDatum.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clearAllPsData() async {
    final db = await database;
    final batch = db.batch();
    batch.delete(psProjectTB);
    batch.delete(psSubProjectTB);
    batch.delete(psLandDataTB);
    batch.delete(psImageDataTB);

    /// Cm Module
    batch.delete(cmBuildingTB);
    batch.delete(cmWingTB);
    // batch.delete(cmProgressTB);
    batch.delete(cmWingSurveyTB);
    batch.delete(locationTB);
    await batch.commit(noResult: true);
  }

  /***************************************** */
  /// Construction Monitoring Module

  static Future<int> cmInsertBuilding({required BuildingData building}) async {
    final db = await database;
    return await db.insert(cmBuildingTB, building.toCMBuildingDB(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<BuildingData>> getCMAllBuildingByPrjId({required int projectId}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        cmBuildingTB,
        where: "project_id = ?",
        whereArgs: [projectId],
      );
      return List.generate(maps.length, (i) {
        return BuildingData.fromJson(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BuildingData>> getCMBuildingByName({required int projectId, required String buildingName}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        cmBuildingTB,
        where: "project_id = ? AND building_name = ?",
        whereArgs: [projectId, buildingName],
      );
      return List.generate(maps.length, (i) {
        return BuildingData.fromJson(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> cmUpdateBuildings({required List<BuildingData> buildings}) async {
    final db = await database;

    final batch = db.batch();

    for (final building in buildings) {
      batch.update(cmBuildingTB, building.toCMBuildingDB(), where: 'id = ?', whereArgs: [building.id]);
    }

    await batch.commit(noResult: true);
  }

  static Future<int> cmDeleteBuilding({required int id}) async {
    final db = await database;
    return await db.delete(cmBuildingTB, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> cmInsertWing({required WingData wing}) async {
    final db = await database;
    return await db.insert(cmWingTB, wing.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateCmWingsByWingId({required WingData wing}) async {
    try {
      final db = await database;
      return await db.update(cmWingTB, wing.toJson(), where: "wing_id = ?", whereArgs: [wing.wingId]);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateCMWings({required List<WingData> wings}) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final wing in wings) {
        batch.update(cmWingTB, wing.toJson(), where: "id = ?", whereArgs: [wing.id]);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> cmDeleteWing({required int id}) async {
    final db = await database;
    return await db.delete(cmWingTB, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<WingData>> getCmAllWings() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(cmWingTB);
      return List.generate(maps.length, (i) {
        return WingData.fromJson(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<WingData>> getCmAllWingsByPrjId({required int projectId}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(cmWingTB, where: "project_id = ?", whereArgs: [projectId]);
      return List.generate(maps.length, (i) {
        return WingData.fromJson(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<WingData>> getCMAllWingsByBuildingId({
    required int projectId,
    int? buildingId,
    String? createdBuildingId,
  }) async {
    try {
      final db = await database;
      String where = "project_id = ?";
      List<dynamic> whereArgs = [projectId];
      if (buildingId != null) {
        where += " AND building_id = ?";
        whereArgs.add(buildingId);
      } else if (createdBuildingId != null) {
        where += " AND createdBuildingId = ?";
        whereArgs.add(createdBuildingId);
      }
      final List<Map<String, dynamic>> maps = await db.query(cmWingTB, where: where, whereArgs: whereArgs);
      return maps.map((e) => WingData.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<WingData>> getCmWingByWingName({
    required int projectId,
    int? buildingId,
    String? createdBuildingId,
    required String wingName,
  }) async {
    try {
      final db = await database;
      String where = "project_id = ? AND wing_name = ?";
      List<dynamic> whereArgs = [projectId, wingName];
      if (buildingId != null) {
        where += " AND building_id = ?";
        whereArgs.add(buildingId);
      } else if (createdBuildingId != null) {
        where += " AND createdBuildingId = ?";
        whereArgs.add(createdBuildingId);
      }
      final List<Map<String, dynamic>> maps = await db.query(cmWingTB, where: where, whereArgs: whereArgs);
      return maps.map((e) => WingData.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> cmInserWingSurvey({required Map<String, dynamic> surveyData}) async {
    try {
      final db = await database;
      return await db.insert(cmWingSurveyTB, surveyData, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> cmGetWingSurveyBywingId({required int wingId}) async {
    try {
      final db = await database;
      return db.query(cmWingSurveyTB, where: "wingId = ?", whereArgs: [wingId]);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CmSurveyModel>> cmGetAllWingSurvey() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> survey = await db.query(cmWingSurveyTB);
      return survey.map((e) => CmSurveyModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> cmGetAllUnsyncWingSurvey({required int wingId}) async {
    try {
      final db = await database;
      return db.query(cmWingSurveyTB, where: "globalSync = ?", whereArgs: [0]);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> cmInsertWingSurvey({required CmSurveyModel surveyData}) async {
    try {
      final db = await database;
      return await db.insert(cmWingSurveyTB, surveyData.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> cmUpdateWingSurvey({required CmSurveyModel surveyData}) async {
    try {
      final db = await database;
      return await db.update(cmWingSurveyTB, surveyData.toJson(), where: "id = ?", whereArgs: [surveyData.id]);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> cmUpdateWingSurveys({required List<CmSurveyModel> surveys}) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final survey in surveys) {
        batch.update(cmWingSurveyTB, survey.toJson(), where: 'id = ?', whereArgs: [survey.id]);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CmSurveyModel>> getAllCmSurveyByWingId({int? wingId, String? localWingId}) async {
    try {
      final db = await database;
      String? where;
      List<dynamic>? whereArgs;
      if (wingId != null && localWingId != null) {
        where = 'wingId = ? AND localWingId = ?';
        whereArgs = [wingId, localWingId];
      } else if (wingId != null) {
        where = 'wingId = ?';
        whereArgs = [wingId];
      } else if (localWingId != null) {
        where = 'localWingId = ?';
        whereArgs = [localWingId];
      }
      final List<Map<String, dynamic>> survey = await db.query(cmWingSurveyTB, where: where, whereArgs: whereArgs);
      return survey.map((e) => CmSurveyModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CmSurveyModel>> getUnsyncCmSurvey() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> survey = await db.query(
        cmWingSurveyTB,
        where: 'localSync = ? AND globalSync = ?',
        whereArgs: [1, 0],
      );
      return survey.map((e) => CmSurveyModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> insertLocation({required LocationModel locationData}) async {
    try {
      final db = await database;
      return await db.insert(locationTB, locationData.toLocationDb());
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<LocationModel>> getAllLocations({required int userId}) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> data = await db.query(locationTB, where: "userId = ?", whereArgs: [userId]);
      return data.map((e) => LocationModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> deleteLocationById({required int id}) async {
    try {
      final db = await database;
      return await db.delete(locationTB, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clearAllCmData() async {
    final db = await database;
    final batch = db.batch();
    batch.delete(cmWingTB);
    batch.delete(cmProgressTB);
    batch.delete(cmWingSurveyTB);
    await batch.commit(noResult: true);
  }

  // ****************** Commercial Module ***************************

  // Insert All City Entity
  static Future<int> cInsertCityEntity(CCityEntity city) async {
    final db = await database;
    return await db.insert(cCityEntity, city.toCCityDB(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch All Cities
  static Future<List<CCityEntity>> cfetchAllCities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(cCityEntity);
    return maps.map((e) => CCityEntity.fromMap(e)).toList();
  }

  // Insert All Suburb Entity
  static Future<int> cInsertSuburbEntity(CSuburbEntity suburb) async {
    final db = await database;
    return await db.insert(cSuburbEntity, suburb.toCSuburbDB(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch All Cities
  static Future<List<CSuburbEntity>> cFetchAllSuburbs({required int cityId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(cSuburbEntity, where: 'cityId = ?', whereArgs: [cityId]);
    return maps.map((e) => CSuburbEntity.fromJson(e)).toList();
  }

  // Insert All Location Entity
  static Future<int> cInsertLocationEntity(CLocationEntity locations) async {
    final db = await database;
    return await db.insert(cLocationEntity, locations.toCLocationDB(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch All Cities
  static Future<List<CLocationEntity>> cFetchAllLocations({required int suburbId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cLocationEntity,
      where: 'suburbId = ?',
      whereArgs: [suburbId],
    );
    return maps.map((e) => CLocationEntity.fromJson(e)).toList();
  }

  // INSERT Commercial SPINNER DATA
  static Future<void> cInsertSpinnerData(CSpinnerData response) async {
    await insertList(cConstProgress, response.constProgressList, (x) => x.toJson());
    await insertList(cProjectStatusEntity, response.projectStatusList, (x) => x.toJson());
    await insertList(cAreaEntity, response.areaUnitList, (x) => x.toJson());
    await insertList(cApproveBanks, response.approvedBankList, (x) => x.toJson());
    await insertList(cAmenties, response.amenitiesList, (x) => x.toJson());
    await insertList(cCityList, response.cityList, (x) => x.toJson());
    await insertList(cOperationModelEntity, response.operatingModelList, (x) => x.toJson());
    await insertList(cBuildingType, response.buildingTypeList, (x) => x.toJson());
    await insertList(cTenantMixEntity, response.tenantMixList, (x) => x.toJson());
  }

  // Get Commercial SPINNER DATA
  static Future<List<Map<String, dynamic>>> cGetConstProgress() => fetchTable(cConstProgress);
  static Future<List<Map<String, dynamic>>> cGetProjectStatus() => fetchTable(cProjectStatusEntity);
  static Future<List<Map<String, dynamic>>> cGetArea() => fetchTable(cAreaEntity);
  static Future<List<Map<String, dynamic>>> cGetApproveBanks() => fetchTable(cApproveBanks);
  static Future<List<Map<String, dynamic>>> cGetAmenties() => fetchTable(cAmenties);
  static Future<List<Map<String, dynamic>>> cGetCityList() => fetchTable(cCityList);
  static Future<List<Map<String, dynamic>>> cGetOperationModel() => fetchTable(cOperationModelEntity);
  static Future<List<Map<String, dynamic>>> cGetBuildingType() => fetchTable(cBuildingType);
  static Future<List<Map<String, dynamic>>> cGetTenantMixEntity() => fetchTable(cTenantMixEntity);
  // Insert Commercial Multi Project
  static Future<int> cInsertMultiProjeject({required List<CProjectEntity> projects}) async {
    final db = await database;
    final batch = db.batch();
    for (final project in projects) {
      batch.insert(cProjectEntity, project.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    final results = await batch.commit();
    return results.length;
  }

  // Insert Single Commercial Project
  static Future<int> cInsertProject({required CProjectEntity project}) async {
    final db = await database;
    final result = await db.insert(cProjectEntity, project.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  // Update Project
  static Future<int> cUpdateProject({required CProjectEntity project}) async {
    final db = await database;
    return await db.update(cProjectEntity, project.toMap(), where: 'projectId = ?', whereArgs: [project.projectId]);
  }

  static Future<int> cUpdateMultipleProjects({required List<CProjectEntity> projects}) async {
    final db = await database;
    final batch = db.batch();
    for (final project in projects) {
      batch.update(cProjectEntity, project.toMap(), where: 'projectId = ?', whereArgs: [project.projectId]);
    }
    final results = await batch.commit(noResult: false);

    /// Count successful updates
    int successCount = results.fold(0, (sum, item) {
      return sum + ((item as int?) ?? 0);
    });
    return successCount;
  }

  /// READ All Project
  static Future<List<CProjectEntity>> cGetProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(cProjectEntity);
    return maps.map((e) => CProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CProjectEntity>> cGetUnsyncProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cProjectEntity,
      where: 'syncGlobalStatus = ? AND syncLocalStatus = ?',
      whereArgs: [0, 1],
    );
    return maps.map((e) => CProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CProjectEntity>> cGetUnsyncProjectsByPrjId({required int projectId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cProjectEntity,
      where: 'syncGlobalStatus = ? AND syncLocalStatus = ? AND projectId = ?',
      whereArgs: [0, 1, projectId],
    );
    return maps.map((e) => CProjectEntity.fromMap(e)).toList();
  }

  /// READ (By ID)
  static Future<CProjectEntity?> cGetPrjById({required int projectId}) async {
    final db = await database;
    final maps = await db.query(cProjectEntity, where: 'projectId = ?', whereArgs: [projectId]);
    if (maps.isNotEmpty) {
      return CProjectEntity.fromMap(maps.first);
    }
    return null;
  }

  // DELETE PROJECT
  static Future<int> cDeletePrjById({required int projectId}) async {
    final db = await database;
    return await db.delete(cProjectEntity, where: 'projectId = ?', whereArgs: [projectId]);
  }

  // Insert Multiple SubProjects
  static Future<int> cInsertMultiSubPrj({required List<CSubProjectEntity> subProjects}) async {
    final db = await database;
    final batch = db.batch();
    for (var sp in subProjects) {
      batch.insert(cSubProjectEntity, sp.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    final results = await batch.commit();
    return results.length;
  }

  // Insert Single Commercial Sub-Project
  static Future<int> cInsertSubPrj({required CSubProjectEntity subPrj}) async {
    final db = await database;
    final result = await db.insert(cSubProjectEntity, subPrj.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  // Update Sub-Project
  static Future<int> cUpdateSubPrj({required CSubProjectEntity subPrj}) async {
    final db = await database;
    return await db.update(
      cSubProjectEntity,
      subPrj.toMap(),
      where: 'subProjectId = ?',
      whereArgs: [subPrj.subProjectId],
    );
  }

  static Future<int> cUpdateMultipleSubPrj({required List<CSubProjectEntity> subProjects}) async {
    final db = await database;
    final batch = db.batch();
    for (final subPrj in subProjects) {
      batch.update(cSubProjectEntity, subPrj.toMap(), where: 'subProjectId = ?', whereArgs: [subPrj.subProjectId]);
    }
    final results = await batch.commit(noResult: false);

    /// Count successful updates
    int successCount = results.fold(0, (sum, item) {
      return sum + ((item as int?) ?? 0);
    });
    return successCount;
  }

  /// READ All Sub-Project
  static Future<List<CSubProjectEntity>> cGetSubProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(cSubProjectEntity);
    return maps.map((e) => CSubProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CSubProjectEntity>> cGetSubProjectsByPrjId({required int projectId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cSubProjectEntity,
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
    return maps.map((e) => CSubProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CSubProjectEntity>> cGetUnsyncSubProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cSubProjectEntity,
      where: 'syncGlobalStatus = ?',
      whereArgs: [0],
    );
    return maps.map((e) => CSubProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CSubProjectEntity>> cGetUnsyncSubProjectsById({required int subProjectId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cSubProjectEntity,
      where: 'syncGlobalStatus = ? AND subProjectId = ?',
      whereArgs: [0, subProjectId],
    );
    return maps.map((e) => CSubProjectEntity.fromMap(e)).toList();
  }

  /// READ (By ID) Sub-Project
  static Future<CSubProjectEntity?> cGetSubPrjById({required int subProjectId}) async {
    final db = await database;
    final maps = await db.query(cSubProjectEntity, where: 'subProjectId = ?', whereArgs: [subProjectId]);
    if (maps.isNotEmpty) {
      return CSubProjectEntity.fromMap(maps.first);
    }
    return null;
  }

  // DELETE  Sub-Project
  static Future<int> cDeleteSubPrjById({required int projectId}) async {
    final db = await database;
    return await db.delete(cSubProjectEntity, where: 'subProjectId = ?', whereArgs: [projectId]);
  }

  // Insert New Project
  static Future<int> cInsertNewProject({required CNewProjectEntity project}) async {
    final db = await database;
    final result = await db.insert(cNewProjectEntity, project.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  static Future<int> cInsertMultiNewProject({required List<CNewProjectEntity> projects}) async {
    final db = await database;
    final batch = db.batch();
    for (var prj in projects) {
      batch.insert(cNewProjectEntity, prj.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    final result = await batch.commit();
    return result.length;
  }

  //Read New Project
  static Future<List<CNewProjectEntity>> cGetAllNewProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(cNewProjectEntity);
    return maps.map((e) => CNewProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CNewProjectEntity>> cGetAllUnsyncNewProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cNewProjectEntity,
      where: 'globalSyncStatus = ?',
      whereArgs: [0],
    );
    return maps.map((e) => CNewProjectEntity.fromMap(e)).toList();
  }

  // Read New Project By Id
  static Future<List<CNewProjectEntity>> cGetNewProjectById({required String prjId}) async {
    final db = await database;
    final maps = await db.query(cNewProjectEntity, where: 'prjId = ?', whereArgs: [prjId]);
    return maps.map((e) => CNewProjectEntity.fromMap(e)).toList();
    // if (maps.isNotEmpty) {
    //   return CNewProjectEntity.fromMap(maps.first);
    // }
    // return null;
  }

  // Update the New Project
  static Future<int> cUpdateNewProject({required CNewProjectEntity project}) async {
    final db = await database;
    return await db.update(cNewProjectEntity, project.toMap(), where: 'prjId = ?', whereArgs: [project.prjId]);
  }

  static Future<int> cUpdateMultipleNewPrj({required List<CNewProjectEntity> projects}) async {
    final db = await database;
    final batch = db.batch();
    for (final prj in projects) {
      batch.update(cNewProjectEntity, prj.toMap(), where: 'prjId = ?', whereArgs: [prj.prjId]);
    }
    final results = await batch.commit(noResult: false);

    /// Count successful updates
    int successCount = results.fold(0, (sum, item) {
      return sum + ((item as int?) ?? 0);
    });
    return successCount;
  }

  static Future<int> cDeleteNewProject({required int id}) async {
    final db = await database;
    return await db.delete(cNewProjectEntity, where: 'prjId = ?', whereArgs: [id]);
  }

  // Add New Sub-Project
  static Future<int> cInsertNewSubProject({required CNewSubProjectEntity subproject}) async {
    final db = await database;
    return await db.insert(cNewSubProjectEntity, subproject.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> cNewInstertMultiSubProject({required List<CNewSubProjectEntity> subprojects}) async {
    final db = await database;
    final batch = db.batch();
    for (var subPrj in subprojects) {
      batch.insert(cNewSubProjectEntity, subPrj.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    final results = await batch.commit();
    return results.length;
  }

  // Get all New Sub-Projects
  static Future<List<CNewSubProjectEntity>> cGetAllNewSubProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(cNewSubProjectEntity);
    return maps.map((e) => CNewSubProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CNewSubProjectEntity>> cGetAllUnsyncNewSubProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cNewSubProjectEntity,
      where: 'globalSyncStatus = ?',
      whereArgs: [0],
    );
    return maps.map((e) => CNewSubProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CNewSubProjectEntity>> cGetAllNewSubProjectsById({int? prjIdLF, String? prjId}) async {
    final db = await database;
    String? where;
    List<Object?> whereArgs = [];
    if (prjIdLF != null && prjId != null) {
      where = 'prjIdLF = ? OR prjId = ?';
      whereArgs = [prjIdLF, prjId];
    } else if (prjIdLF != null) {
      where = 'prjIdLF = ?';
      whereArgs = [prjIdLF];
    } else if (prjId != null) {
      where = 'prjId = ?';
      whereArgs = [prjId];
    } else {
      // No filters → return all or empty
      return [];
    }

    final maps = await db.query(cNewSubProjectEntity, where: where, whereArgs: whereArgs);

    return maps.map((e) => CNewSubProjectEntity.fromMap(e)).toList();
  }

  static Future<List<CNewSubProjectEntity>> cGetNewSubProjectById({required String subprojectId}) async {
    final db = await database;
    final maps = await db.query(cNewSubProjectEntity, where: 'subPrjId = ?', whereArgs: [subprojectId]);
    return maps.map((e) => CNewSubProjectEntity.fromMap(e)).toList();
  }

  static Future<int> cUpdateNewSubProject({required CNewSubProjectEntity subproject}) async {
    final db = await database;
    return await db.update(
      cNewSubProjectEntity,
      subproject.toMap(),
      where: 'subPrjId = ?',
      whereArgs: [subproject.subPrjId],
    );
  }

  static Future<int> cUpdateMultiNewSubPrj({required List<CNewSubProjectEntity> subprojects}) async {
    final db = await database;
    final batch = db.batch();
    for (var subprj in subprojects) {
      batch.update(cNewSubProjectEntity, subprj.toMap(), where: 'subPrjId = ?', whereArgs: [subprj.subPrjId]);
    }
    final results = await batch.commit(noResult: false);

    /// Count successful updates
    int successCount = results.fold(0, (sum, item) {
      return sum + ((item as int?) ?? 0);
    });
    return successCount;
  }

  static Future<int> cDeleteNewSubProject({required String subprojectId}) async {
    final db = await database;
    return await db.delete(cNewSubProjectEntity, where: 'subPrjId = ?', whereArgs: [subprojectId]);
  }

  static Future<void> clearComAllData() async {
    final db = await database;
    final batch = db.batch();
    batch.delete(cCityEntity);
    batch.delete(cSuburbEntity);
    batch.delete(cLocationEntity);
    batch.delete(cConstProgress);
    batch.delete(cProjectStatusEntity);
    batch.delete(cAreaEntity);
    batch.delete(cApproveBanks);
    batch.delete(cAmenties);
    batch.delete(cCityList);
    batch.delete(cOperationModelEntity);
    batch.delete(cBuildingType);
    batch.delete(cTenantMixEntity);
    batch.delete(cNewProjectEntity);
    batch.delete(cNewSubProjectEntity);
    batch.delete(cProjectEntity);
    batch.delete(cSubProjectEntity);
    await batch.commit(noResult: true);
  }
}
