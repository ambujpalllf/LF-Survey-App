import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';

class LocationViewPage extends StatefulWidget {
  final List<ProjectEntity> resiProject;
  final List<CProjectEntity> commercialProject;
  final String type;

  const LocationViewPage({super.key, required this.resiProject, required this.commercialProject, required this.type});

  @override
  State<LocationViewPage> createState() => _LocationViewPageState();
}

class _LocationViewPageState extends State<LocationViewPage> {
  GoogleMapController? mapController;
  MapType mapType = MapType.hybrid;

  LatLng? _center;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _loadProjectsOnMap();
  }

  void _loadProjectsOnMap() {
    try {
      final List<Map<String, dynamic>> projects = widget.resiProject.isNotEmpty
          ? widget.resiProject
                .map(
                  (e) => {
                    "projectName": e.projectName,
                    "projectAddress": e.projectAddress,
                    "lat": e.pxval,
                    "lng": e.pyval,
                  },
                )
                .toList()
          : widget.commercialProject
                .map(
                  (e) => {
                    "projectName": e.projectName,
                    "projectAddress": e.projectAddress,
                    "lat": e.pxval,
                    "lng": e.pyval,
                  },
                )
                .toList();

      if (projects.isEmpty) return;

      final Set<Marker> tempMarkers = {};

      for (int i = 0; i < projects.length; i++) {
        final project = projects[i];

        final latLng = LatLng(project["lat"], project["lng"]);
        final bool isFProject = project["projectName"].toString().contains("(F)");
        tempMarkers.add(
          Marker(
            markerId: MarkerId(i.toString()),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isFProject ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: project["projectName"],
              snippet: project["projectAddress"],
              onTap: () {
                if (widget.type == "resi") {
                  context.pushNamed(AppRoutesName.projectDetailsPage, extra: {"projectData": widget.resiProject[i]});
                } else {
                  context.pushNamed(
                    AppRoutesName.cProjectDetailsPage,
                    extra: {"projectData": widget.commercialProject[i]},
                  );
                }
              },
            ),
          ),
        );

        // Set center using first project
        if (i == 0) {
          _center = latLng;
        }
      }

      setState(() {
        markers = tempMarkers;
      });
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      CustomSnackHelper.customToastMsg(context: context, message: erMsg);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _toggleMapType() {
    setState(() {
      switch (mapType) {
        // case MapType.normal:
        //   mapType = MapType.satellite;
        //   break;
        case MapType.satellite:
          mapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          mapType = MapType.terrain;
          break;
        // case MapType.terrain:
        //   mapType = MapType.normal;
        //   break;
        default:
          mapType = MapType.hybrid;
      }
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prevent crash while center is loading
    // if (_center == null) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    return SafeArea(
      child: Scaffold(
        body: _center == null
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(target: _center!, zoom: 12),
                    mapType: mapType,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: markers,
                  ),

                  Positioned(
                    top: 60,
                    right: 10,
                    child: InkWell(
                      onTap: _toggleMapType,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(100)),
                        child: Icon(Icons.satellite, size: 27),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
