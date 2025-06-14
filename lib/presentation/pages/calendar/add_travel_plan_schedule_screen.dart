import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:personalized_travel_recommendations/core/theme/app_colors.dart';
import 'package:personalized_travel_recommendations/core/theme/app_outline_png_icons.dart';
import 'package:personalized_travel_recommendations/core/theme/app_text_styles.dart';
import 'package:personalized_travel_recommendations/presentation/pages/calendar/calendar_screen.dart';
import 'package:personalized_travel_recommendations/presentation/pages/calendar/package_screen.dart';

class AddTravelPlanScheduleScreen extends StatefulWidget {
  final String country;
  final String city;
  const AddTravelPlanScheduleScreen({super.key, required this.country, required this.city});

  @override
  State<AddTravelPlanScheduleScreen> createState() =>
      _AddTravelPlanScheduleScreen();
}

class _AddTravelPlanScheduleScreen extends State<AddTravelPlanScheduleScreen> {
  TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  String _titleEditButtonText = '편집';
  bool _isReadOnlyTitleEdit = true;

  late Map travelInfo = {
    'title': '${widget.city} 여행',
    'startDay': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    'endDay': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    'period': 1,
    'country': widget.country,
    'city': widget.city,
    'hashtag': [],
    'price':0,
  };

  late GoogleMapController mapController;
  final LatLng _center = LatLng(37.5665, 126.9780);

  final List<Map> _rcmndPkgList = [
    {
      'user':'고병지',
      'title':'도쿄 10대 맛집 부수기',
      'startDay':DateTime.utc(2025,3,18),
      'endDay':DateTime.utc(2025,3,20),
      'period':3,
      'country':'일본',
      'city':'도쿄',
      'hashtag':['친구와','1개 도시','맛집 투어'],
      'price':10000,
      'thumbnail':'assets/images/TokyoRestaurants.png',
    },
    {
      'user':'권도예',
      'title':'도쿄 10대 맛집 부수기',
      'startDay':DateTime.utc(2025,3,18),
      'endDay':DateTime.utc(2025,3,20),
      'period':3,
      'country':'일본',
      'city':'도쿄',
      'hashtag':['친구와','1개 도시','맛집 투어'],
      'price':10000,
      'thumbnail':'assets/images/TokyoRestaurants.png',
    },
    {
      'user':'김영은',
      'title':'도쿄 10대 맛집 부수기',
      'startDay':DateTime.utc(2025,3,18),
      'endDay':DateTime.utc(2025,3,20),
      'period':3,
      'country':'일본',
      'city':'도쿄',
      'hashtag':['친구와','1개 도시','맛집 투어'],
      'price':10000,
      'thumbnail':'assets/images/TokyoRestaurants.png',
    },
    {
      'user':'박재성',
      'title':'도쿄 10대 맛집 부수기',
      'startDay':DateTime.utc(2025,3,18),
      'endDay':DateTime.utc(2025,3,20),
      'period':3,
      'country':'일본',
      'city':'도쿄',
      'hashtag':['친구와','1개 도시','맛집 투어'],
      'price':10000,
      'thumbnail':'assets/images/TokyoRestaurants.png',
    },
    {
      'user':'이겅현',
      'title':'도쿄 10대 맛집 부수기',
      'startDay':DateTime.utc(2025,3,18),
      'endDay':DateTime.utc(2025,3,20),
      'period':3,
      'country':'일본',
      'city':'도쿄',
      'hashtag':['친구와','1개 도시','맛집 투어'],
      'price':10000,
      'thumbnail':'assets/images/TokyoRestaurants.png',
    },
  ];

  // 'place':<String>,
  // 'address':<String>,
  // 'price':<Double>,
  // 'time':<TimeOfDay(hour: 11, minute: 25)>,
  List<List<Map>> travelSchedule = [[]];

  List<Color> travelDailyColors = [
    AppColors.cyan20,
    AppColors.lime20,
    AppColors.purple20,
  ];

  List<TextEditingController> _hashtagController = [];
  bool _isRelease = true;

  final TextEditingController _priceController = TextEditingController(text: '₩');

  void _editTitle() {
    setState(() {
      if (_titleEditButtonText == '확인') {
        _titleFocus.unfocus();
        _titleEditButtonText = '편집';
        _isReadOnlyTitleEdit = true;
        travelInfo['title'] = _titleController.text;
      } else {
        FocusScope.of(context).requestFocus(_titleFocus);
        _titleEditButtonText = '확인';
        _isReadOnlyTitleEdit = false;
      }
    });
  }

  void _setDate(int knd) async {
    final DateTime? dateTime = await showDatePicker(
      context: context,
      firstDate: DateTime.utc(2025,1,1),
      lastDate: DateTime.utc(2025,12,31),
      initialDate: knd == 0 ? travelInfo['startDay'] : travelInfo['endDay'],
    );
    if (dateTime != null) {
      setState(() {
        if (knd == 0) {
          travelInfo['startDay'] = dateTime;
          if (travelInfo['startDay'].isAfter(travelInfo['endDay'])) {
            travelInfo['endDay'] = dateTime;
          }
        } else {
          travelInfo['endDay'] = dateTime;
          if (travelInfo['endDay'].isBefore(travelInfo['startDay'])) {
            travelInfo['startDay'] = dateTime;
          }
        }

        travelInfo['period'] = travelInfo['endDay'].difference(travelInfo['startDay']).inDays + 1;

        travelSchedule.clear();
        for (int i = 0; i < travelInfo['period']; i++) {
          travelSchedule.add([]);
        }
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addSchedule(int travelIndex) {
    setState(() {
      travelSchedule[travelIndex].add(
          {
            'place': '',
            'address': '',
            'price': 0,
            'time': TimeOfDay(hour: 0, minute: 0),
          }
      );
    });
  }

  void _removeSchedule(int travelIndex, int scheduleIndex) {
    setState(() {
      travelSchedule[travelIndex].removeAt(scheduleIndex);
    });
  }

  void _addHashtag () {
    setState(() {
      _hashtagController.add(TextEditingController(text: '#'));
      travelInfo['hashtag'].add('');
    });
  }

  void _removeHashtag (int index) {
    setState(() {
      travelInfo['hashtag'].removeAt(index);
      _hashtagController.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: travelInfo['title']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 53,
              // margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 2.0, color: AppColors.neutral20),
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(28)),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.neutral10,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AppOutlinePngIcons.arrowNarrowLeft(color: Colors.black, size: 20,),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      "여행 추가",
                      style: AppTypography.subtitle16SemiBold.copyWith(color: AppColors.neutral100),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const TravelCalendarScreen(),
                              ),
                                  (route) => false,
                            ),
                          },
                          child: Text( "등록", style: AppTypography.subtitle16SemiBold.copyWith(color: AppColors.indigo60),),
                        ),
                      )
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: TextField(
                              controller: _titleController,
                              readOnly: _isReadOnlyTitleEdit,
                              focusNode: _titleFocus,
                              decoration: const InputDecoration(
                                hintText: '제목을 입력하세요',
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.neutral40,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              style: _titleFocus.hasFocus ? AppTypography.body14Medium : AppTypography.subtitle18SemiBold,
                            ),
                          ),
                          TextButton(
                            onPressed: _editTitle,
                            child: Text(_titleEditButtonText, style: AppTypography.body14Medium.copyWith(color: AppColors.neutral100),),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppOutlinePngIcons.calendar(),
                          TextButton(
                            onPressed: () => _setDate(0),
                            child: Text(
                              // '${startDay.year}.${startDay.month}.${startDay.day}',
                              '${travelInfo['startDay'].year}.${travelInfo['startDay'].month}.${travelInfo['startDay'].day}',
                              style: AppTypography.caption12Medium.copyWith(color: AppColors.neutral100),
                            ),
                          ),
                          Text('~', style: AppTypography.caption12Medium.copyWith(color: AppColors.neutral100),),
                          TextButton(
                            onPressed: () => _setDate(1),
                            child: Text(
                              // '${endDay.year}.${endDay.month}.${endDay.day}',
                              '${travelInfo['endDay'].year}.${travelInfo['endDay'].month}.${travelInfo['endDay'].day}',
                              style: AppTypography.caption12Medium.copyWith(color: AppColors.neutral100),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 160,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 16.0,
                          ),
                          myLocationEnabled: true,
                          zoomControlsEnabled: true,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '추천 패키지',
                            style: AppTypography.subtitle18Bold,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          // width: 349,
                          height: 106,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(_rcmndPkgList.length, (index) {
                                return Padding(
                                  padding: _rcmndPkgList.length-1 == index ? const EdgeInsets.fromLTRB(0, 0, 0, 0) : const EdgeInsets.fromLTRB(0, 0, 26, 0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 74,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.neutral40),
                                        ),
                                        child: Center(
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(
                                              shape: const CircleBorder(),
                                              fixedSize: const Size(64, 64),
                                              padding: const EdgeInsets.all(0),
                                              side: const BorderSide(color: AppColors.neutral40),
                                              backgroundColor: AppColors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => TravelPackage(travelInfo: _rcmndPkgList[index],),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(image: AssetImage(_rcmndPkgList[index]['thumbnail']),),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text('${_rcmndPkgList[index]['user']} 님', style: AppTypography.body14Medium.copyWith(color: AppColors.neutral100),),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Divider(
                          thickness: 1,
                          color: AppColors.neutral40,
                        ),
                      ),
                      Column(
                        children: List.generate(travelInfo['period'], (periodIndex){
                          return ListTileTheme(
                            contentPadding: const EdgeInsets.all(0),
                            child: ExpansionTile(
                              shape: const Border(),
                              controlAffinity: ListTileControlAffinity.leading,
                              expandedAlignment: Alignment.topLeft,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text('${periodIndex+1}일 차',style: AppTypography.subtitle16SemiBold,),
                                      const Padding(padding: EdgeInsets.only(left: 10)),
                                      Text(
                                        '${travelInfo['startDay'].add(Duration(days: periodIndex)).month}월 ${travelInfo['startDay'].add(Duration(days: periodIndex)).day}일',
                                        style: AppTypography.caption12Regular.copyWith(color: AppColors.neutral60),
                                      ),
                                    ],
                                  ),
                                  IconButton(onPressed: () => _addSchedule(periodIndex), icon: AppOutlinePngIcons.plus()),
                                ],
                              ),
                              children: [
                                ...List.generate(travelSchedule[periodIndex].length, (scheduleIndex) {
                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: ShapeDecoration(
                                                      shape: const CircleBorder(),
                                                      color: travelDailyColors[periodIndex],
                                                    ),
                                                    child: Center(child: Text('${scheduleIndex+1}', style: AppTypography.body16Medium.copyWith(color: AppColors.white),),),
                                                  ),
                                                  const Padding(padding: EdgeInsets.only(top: 10),),
                                                  Text('${travelSchedule[periodIndex][scheduleIndex]['time'].hour}:${travelSchedule[periodIndex][scheduleIndex]['time'].minute}', style: AppTypography.body14Medium.copyWith(color: AppColors.neutral100,),),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                                      color: AppColors.neutral20,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children:[
                                                        Text(travelSchedule[periodIndex][scheduleIndex]['place'], style: AppTypography.body14Medium.copyWith(color: AppColors.neutral100),),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            AppOutlinePngIcons.locationMarker(size: 16, color: AppColors.neutral60,),
                                                            const Padding(padding: EdgeInsets.only(left: 6),),
                                                            Flexible(child: Text(travelSchedule[periodIndex][scheduleIndex]['address'], style: AppTypography.caption12Regular.copyWith(color: AppColors.neutral60),),),
                                                          ],
                                                        ),
                                                        if (travelSchedule[periodIndex][scheduleIndex]['price'] > 0) Text('₩ ${NumberFormat('#,###').format(travelSchedule[periodIndex][scheduleIndex]['price'])}', style: AppTypography.subtitle18Bold.copyWith(color: AppColors.indigo60),),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: -10,
                                                    right: -10,
                                                    child: IconButton(
                                                      onPressed: () => _removeSchedule(periodIndex, scheduleIndex),
                                                      icon: AppOutlinePngIcons.x(color: AppColors.neutral80, size: 12,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (travelSchedule[periodIndex].length-1 != scheduleIndex) AppOutlinePngIcons.dotsVertical(size: 16, color: AppColors.neutral40),
                                    ],
                                  );
                                }),
                                if (travelSchedule[periodIndex].isEmpty)
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: ShapeDecoration(
                                                shape: const CircleBorder(),
                                                color: travelDailyColors[periodIndex%3]
                                            ),
                                            child: Center(child: Text('1', style: AppTypography.body16Medium.copyWith(color: AppColors.white),),),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(12)),
                                              color: AppColors.neutral20,
                                            ),
                                            child: const Text(
                                              '일정을 추가해주세요.',
                                              style: AppTypography.body14Medium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '테마 해시태그',
                            style: AppTypography.subtitle16SemiBold,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '최대 3개가지 선택 가능합니다.',
                          style: AppTypography.caption12Regular,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Container(
                        height: 100,
                        decoration: const BoxDecoration(
                          color: AppColors.neutral20,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ...List.generate(travelInfo['hashtag'].length, (index) {
                              return SizedBox(
                                width: 86,
                                height: 48,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.indigo60,
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: Center(
                                          child: TextField(
                                            controller: _hashtagController[index],
                                            maxLength: 6,
                                            textAlign: TextAlign.center,
                                            inputFormatters: [PrefixInputFormatter('#')],
                                            style: AppTypography.body14SemiBold.copyWith(color: AppColors.white),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(bottom: 8),
                                            ),
                                            onEditingComplete: () => {
                                              setState(() {
                                                travelInfo['hashtag'][index] = _hashtagController[index].text.replaceFirst('#', '');
                                              }),
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: IconButton(
                                          style: IconButton.styleFrom(
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(0),
                                            backgroundColor: AppColors.white,
                                            disabledBackgroundColor: AppColors.white,
                                          ),
                                          onPressed: () => _removeHashtag(index),
                                          icon: AppOutlinePngIcons.x(color: AppColors.neutral80,),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (travelInfo['hashtag'].length < 3)
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  style: IconButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(0),
                                    backgroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors.white,
                                  ),
                                  onPressed: _isRelease ? _addHashtag : null,
                                  icon: AppOutlinePngIcons.plus(color: _isRelease ? AppColors.neutral80 : AppColors.neutral40,),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '패키지 공개 / 비공개',
                            style: AppTypography.subtitle16SemiBold,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: RadioListTile(
                              title: const Text('공개', style: AppTypography.body14Regular,),
                              value: true,
                              groupValue: _isRelease,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isRelease = value!;
                                });
                              },
                              activeColor: AppColors.indigo60,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: RadioListTile(
                              title: const Text('비공개', style: AppTypography.body14Regular,),
                              value: false,
                              groupValue: _isRelease,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isRelease = value!;
                                });
                              },
                              activeColor: AppColors.indigo60,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '판매 금액',
                            style: AppTypography.subtitle16SemiBold,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: TextField(
                          controller: _priceController,
                          style: AppTypography.body16Medium,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.neutral40,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.neutral40,
                                width: 0.5,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CommaFormatter(),
                            PrefixInputFormatter('₩'),
                          ],
                          onEditingComplete: () => {
                            setState(() {
                              travelInfo['price'] = double.parse(_priceController.text.replaceFirst('₩', ''));
                            }),
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommaFormatter extends TextInputFormatter {
  CommaFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final numberStr = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final int parsedInt = int.parse(numberStr);
    final formatter = NumberFormat.currency(locale: 'ko', symbol: '');
    String newText = formatter.format(parsedInt);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
    );
  }
}

class PrefixInputFormatter extends TextInputFormatter {
  final String prefix;

  PrefixInputFormatter(this.prefix);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (!newValue.text.startsWith(prefix)) {
      final newText = prefix + newValue.text.replaceFirst(prefix, '');
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return newValue;
  }
}
