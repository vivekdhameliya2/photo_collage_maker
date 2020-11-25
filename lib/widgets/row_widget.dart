import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_collage_widget/blocs/collage_bloc.dart';
import 'package:image_collage_widget/blocs/collage_state.dart';
import 'package:image_collage_widget/model/images.dart';
import 'package:image_collage_widget/utils/CollageType.dart';
import 'package:image_collage_widget/utils/permission_type.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class GridCollageWidget extends StatelessWidget {
  var imageList = List<Images>();
  final CollageType collageType;
  final CollageBloc imageListBloc;

  GridCollageWidget(this.collageType, this.imageListBloc);

  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    if (imageListBloc.currentState is ImageListState) {
      imageList = (imageListBloc.currentState as ImageListState).images;
      return Container(
        color: Color(0xff4E5267),
        child: StaggeredGridView.countBuilder(
          physics: NeverScrollableScrollPhysics(),
            shrinkWrap: false,
            itemCount: imageList.length,
            crossAxisCount: getCrossAxisCount(collageType),
            primary: true,
            itemBuilder: (BuildContext context, int index) => buildRow(index),
            staggeredTileBuilder: (int index) => StaggeredTile.count(
                getCellCount(
                    index: index, isForCrossAxis: true, type: collageType),
                getCellCount(
                    index: index, isForCrossAxis: false, type: collageType))),
      );
    }
  }

  buildRow(int index) {
    final ValueNotifier<Matrix4> matrix = ValueNotifier(Matrix4.identity());

    return Stack(
      fit: StackFit.expand,
//      splashColor: Colors.blue[100],
//      highlightColor: Colors.blue[200],
//      onTap: () => showDialogImage(index),
      children: <Widget>[
        Positioned.fill(
          bottom: 0.0,
          child: Container(
            child: imageList[index].imageUrl != null
                ? Container(
                    width: 100.0,
                    height: 300.0,
                    color: Colors.black,
                    child: MatrixGestureDetector(
                      onMatrixUpdate: (m, tm, sm, rm) {
                        matrix.value = m;
                      },
                      child: AnimatedBuilder(
                        animation: matrix,
                        builder: (context, child) {
                          return Transform(
                            transform: matrix.value,
                            child: GestureDetector(
                              onTap: () => showDialogImage(index),
                              child: Image.file(
                                imageList[index].imageUrl,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => showDialogImage(index),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: Material(
                        child: Icon(Icons.add),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color(0xFFD3D3D3),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  imagePickerDialog(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildDialogOption(index, isForStorage: false),
                  buildDialogOption(index),
                  (imageListBloc.currentState as ImageListState)
                              .images[index]
                              .imageUrl !=
                          null
                      ? buildDialogOption(index, isForRemovePhoto: true)
                      : Container(),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  dismissDialog();
                },
                child: Text("Cancel"),
              )
            ],
          );
        });
  }

  showDialogImage(int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Color(0xFF737373),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildDialogOption(index, isForStorage: false),
                    buildDialogOption(index),
                    (imageListBloc.currentState as ImageListState)
                                .images[index]
                                .imageUrl !=
                            null
                        ? buildDialogOption(index, isForRemovePhoto: true)
                        : Container(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  dismissDialog() {
    Navigator.of(context, rootNavigator: true).pop(true);
  }

  Widget buildDialogOption(int index,
      {bool isForStorage = true, bool isForRemovePhoto = false}) {
    return FlatButton(
        onPressed: () {
          dismissDialog();
          isForRemovePhoto
              ? imageListBloc.dispatchRemovePhotoEvent(index)
              : imageListBloc.dispatchCheckPermissionEvent(
                  permissionType: isForStorage
                      ? PermissionType.Storage
                      : PermissionType.Camera,
                  index: index,
                  isFromPicker: true);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  isForRemovePhoto
                      ? Icons.clear
                      : isForStorage
                          ? Icons.photo_album
                          : Icons.add_a_photo,
                  color: isForRemovePhoto
                      ? Colors.red
                      : isForStorage
                          ? Colors.amber
                          : Colors.blue,
                ),
              ),
              Text(isForRemovePhoto
                  ? "Remove"
                  : isForStorage
                      ? "Gallery"
                      : "Camera")
            ],
          ),
        ));
  }

  /// @param index:- index of image.
  /// @param isForCrossAxis = if from cross axis count = true
  /// Note:- If row == column then crossAxisCount = row*column // rowCount or columnCount
  /// e.g. row = 3 and column = 3 then crossAxisCount = 3*3(9) or 3
  getCellCount(
      {@required int index, bool isForCrossAxis, @required CollageType type}) {
    /// total cell count :- 2
    /// Column and Row :- 2*1 = 2 (Cross axis count)

    if (type == CollageType.VSplit) {
      if (isForCrossAxis)

        /// Cross axis cell count
        return 1;
      else

        /// Main axis cell count
        return 2;
    }

    /// total cell count :- 2
    /// Column and Row :- 1*2 = 2 (Cross axis count)

    else if (type == CollageType.HSplit) {
      if (isForCrossAxis)

        /// Cross axis cell count
        return 2;
      else

        /// Main axis cell count
        return 1;
    }

    /// total cell count :- 4
    /// Column and Row :- 2*2 (Cross axis count)

    else if (type == CollageType.FourSquare) {
      /// cross axis and main axis cell count
      return 2;
    }

    /// total cell count :- 9
    /// Column and Row :- 3*3 (Cross axis count)
    else if (type == CollageType.NineSquare) {
      return 3;
    }

    /// total cell count :- 3
    /// Column and Row :- 2 * 2
    /// First index taking 2 cell count in main axis and also in cross axis.
    else if (type == CollageType.ThreeVertical) {
      if (isForCrossAxis) {
        return 1;
      } else
        return (index == 0) ? 2 : 1;
    } else if (type == CollageType.ThreeHorizontal) {
      if (isForCrossAxis) {
        return (index == 0) ? 2 : 1;
      } else
        return 1;
    }

    /// total cell count :- 6
    /// Column and Row :- 3 * 3
    /// First index taking 2 cell in main axis and also in cross axis.
    /// Cross axis count = 3

    else if (type == CollageType.LeftBig) {
      if (isForCrossAxis) {
        return (index == 0) ? 2 : 1;
      } else
        return (index == 0) ? 2 : 1;
    } else if (type == CollageType.RightBig) {
      if (isForCrossAxis) {
        return (index == 1) ? 2 : 1;
      } else
        return (index == 1) ? 2 : 1;
    } else if (type == CollageType.FourLeftBig) {
      if (isForCrossAxis) {
        return (index == 0) ? 2 : 1;
      } else
        return (index == 0) ? 3 : 1;

      /// total tile count (image count)--> 7
      /// Column: Row (2:3)
      /// First column :- 3 tile
      /// Second column :- 4 tile
      /// First column 3 tile taking second column's 4 tile space. So total tile count is 4*3=12(cross axis count).
      /// First column each cross axis tile count = cross axis count/ total tile count(In cross axis)  {12/3 = 4]
      /// Second column cross axis cell count :- 12/4 = 3
      /// Main axis count : Cross axis count / column count {12/2 = 6}
    } else if (type == CollageType.VMiddleTwo) {
      if (isForCrossAxis) {
        return 6;
      } else
        return (index == 0 || index == 3 || index == 5) ? 4 : 3;
    }

    /// total tile count (image count)--> 7
    /// left, right and center  - 3/3/1
    /// total column:- 3
    /// total row :- 4 (total row is 3 but column 2 taking 2 row space so left + center + right = 1+2+1 {4}).
    /// cross axis count = total column * total row {3*4 = 12}.
    /// First/Third column each cross axis tile count = cross axis count / total tile count(In cross axis) = 12 / 3 = 4
    /// First/Third column each main axis tile count = cross axis count / total tile count(In main axis) = 12 / 4 = 3
    /// Second each cross axis tile count = cross axis count / total tile count(In cross axis) = 12/1 = 12
    /// Second each main axis tile count = cross axis count / total tile count(In main axis) = 12/2 = 6

    else if (type == CollageType.CenterBig) {
      if (isForCrossAxis) {
        return (index == 1) ? 6 : 3;
      } else
        return (index == 1) ? 12 : 4;
    }
  }

  getCrossAxisCount(CollageType type) {
    if (type == CollageType.HSplit ||
        type == CollageType.VSplit ||
        type == CollageType.ThreeHorizontal ||
        type == CollageType.ThreeVertical)
      return 2;
    else if (type == CollageType.FourSquare)
      return 4;
    else if (type == CollageType.NineSquare)
      return 9;
    else if (type == CollageType.LeftBig || type == CollageType.RightBig)
      return 3;
    else if (type == CollageType.FourLeftBig)
      return 3;
    else if (type == CollageType.VMiddleTwo || type == CollageType.CenterBig)
      return 12;
  }
}
