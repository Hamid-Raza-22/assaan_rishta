// import 'package:assaan_rishta/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'export.dart';
import '../core/export.dart';
import '../core/utils/screen_security.dart';
import '../utils/exports.dart';

class PhotoGalleryView extends StatefulWidget {
  final List<VendorAlbums> imageList;
  final BuildContext context;
  final int selectedIndex;

  const PhotoGalleryView({
    super.key,
    required this.imageList,
    required this.context,
    required this.selectedIndex,
  });

  @override
  State<PhotoGalleryView> createState() => _PhotoGalleryViewState();
}

class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  @override
  void initState() {
    super.initState();
    
    // Enable screen security (block screenshots & recording)
    ScreenSecurity.enableScreenSecurity();
  }

  @override
  void dispose() {
    // Disable screen security when leaving gallery
    ScreenSecurity.disableScreenSecurity();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: CustomAppBar(
          isBack: true,
          title: "Albums",
          color: AppColors.blackColor,
          textColor: AppColors.whiteColor,
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        pageSnapping: true,
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
              widget.imageList[index].imagesName!,
            ),
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.imageList[index].imagesID!,
            ),
          );
        },
        itemCount: widget.imageList.length,
        loadingBuilder: (context, event) => const Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(),
          ),
        ),
        backgroundDecoration: const BoxDecoration(
          color: AppColors.blackColor,
        ),
        pageController: PageController(
          initialPage: widget.selectedIndex,
        ),
        onPageChanged: (index) {},
      ),
    );
  }
}
