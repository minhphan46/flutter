// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_input_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ScribbleClient showToolbar method is called', () async {
    final FakeScribbleElement targetElement = FakeScribbleElement(elementIdentifier: 'target');
    Scribble.client = targetElement;

    expect(targetElement.latestMethodCall, isEmpty);

    // Send showToolbar message.
    final ByteData? messageBytes =
        const JSONMessageCodec().encodeMessage(<String, dynamic>{
      'args': <dynamic>[1, 0, 1],
      'method': 'Scribble.showToolbar',
    });
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/scribble',
      messageBytes,
      (ByteData? _) {},
    );

    expect(targetElement.latestMethodCall, 'showToolbar');
  });

  test('ScribbleClient removeTextPlaceholder method is called', () async {
    final FakeScribbleElement targetElement = FakeScribbleElement(elementIdentifier: 'target');
    Scribble.client = targetElement;

    expect(targetElement.latestMethodCall, isEmpty);

    // Send removeTextPlaceholder message.
    final ByteData? messageBytes =
        const JSONMessageCodec().encodeMessage(<String, dynamic>{
      'args': <dynamic>[1, 0, 1],
      'method': 'Scribble.removeTextPlaceholder',
    });
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/scribble',
      messageBytes,
      (ByteData? _) {},
    );

    expect(targetElement.latestMethodCall, 'removeTextPlaceholder');
  });

  test('ScribbleClient insertTextPlaceholder method is called', () async {
    final FakeScribbleElement targetElement = FakeScribbleElement(elementIdentifier: 'target');
    Scribble.client = targetElement;

    expect(targetElement.latestMethodCall, isEmpty);

    // Send insertTextPlaceholder message.
    final ByteData? messageBytes =
        const JSONMessageCodec().encodeMessage(<String, dynamic>{
      'args': <dynamic>[1, 0, 1],
      'method': 'Scribble.insertTextPlaceholder',
    });
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/scribble',
      messageBytes,
      (ByteData? _) {},
    );

    expect(targetElement.latestMethodCall, 'insertTextPlaceholder');
  });

  test('ScribbleClient scribbleInteractionBegan and scribbleInteractionFinished', () async {
    Scribble.ensureInitialized();

    expect(Scribble.scribbleInProgress, isFalse);

    // Send scribbleInteractionBegan message.
    ByteData? messageBytes =
        const JSONMessageCodec().encodeMessage(<String, dynamic>{
      'args': <dynamic>[1, 0, 1],
      'method': 'Scribble.scribbleInteractionBegan',
    });
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/scribble',
      messageBytes,
      (ByteData? _) {},
    );

    expect(Scribble.scribbleInProgress, isTrue);

    // Send scribbleInteractionFinished message.
    messageBytes =
        const JSONMessageCodec().encodeMessage(<String, dynamic>{
      'args': <dynamic>[1, 0, 1],
      'method': 'Scribble.scribbleInteractionFinished',
    });
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/scribble',
      messageBytes,
      (ByteData? _) {},
    );

    expect(Scribble.scribbleInProgress, isFalse);
  });

  test('ScribbleClient focusElement', () async {
    final FakeScribbleElement targetElement = FakeScribbleElement(elementIdentifier: 'target');
    Scribble.registerScribbleElement(targetElement.elementIdentifier, targetElement);
    final FakeScribbleElement otherElement = FakeScribbleElement(elementIdentifier: 'other');
    Scribble.registerScribbleElement(otherElement.elementIdentifier, otherElement);

    expect(targetElement.latestMethodCall, isEmpty);
    expect(otherElement.latestMethodCall, isEmpty);

    // Send focusElement message.
    final ByteData? messageBytes =
        const JSONMessageCodec().encodeMessage(<String, dynamic>{
      'args': <dynamic>[targetElement.elementIdentifier, 0.0, 0.0],
      'method': 'Scribble.focusElement',
    });
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/scribble',
      messageBytes,
      (ByteData? _) {},
    );

    Scribble.unregisterScribbleElement(targetElement.elementIdentifier);
    Scribble.unregisterScribbleElement(otherElement.elementIdentifier);

    expect(targetElement.latestMethodCall, 'onScribbleFocus');
    expect(otherElement.latestMethodCall, isEmpty);
  });

  test('ScribbleClient requestElementsInRect', () async {
    final List<FakeScribbleElement> targetElements = <FakeScribbleElement>[
      FakeScribbleElement(elementIdentifier: 'target1', bounds: const Rect.fromLTWH(0.0, 0.0, 100.0, 100.0)),
      FakeScribbleElement(elementIdentifier: 'target2', bounds: const Rect.fromLTWH(0.0, 100.0, 100.0, 100.0)),
    ];
    final List<FakeScribbleElement> otherElements = <FakeScribbleElement>[
      FakeScribbleElement(elementIdentifier: 'other1', bounds: const Rect.fromLTWH(100.0, 0.0, 100.0, 100.0)),
      FakeScribbleElement(elementIdentifier: 'other2', bounds: const Rect.fromLTWH(100.0, 100.0, 100.0, 100.0)),
    ];

    void registerElements(FakeScribbleElement element) => Scribble.registerScribbleElement(element.elementIdentifier, element);
    void unregisterElements(FakeScribbleElement element) => Scribble.unregisterScribbleElement(element.elementIdentifier);

    <FakeScribbleElement>[...targetElements, ...otherElements].forEach(registerElements);

    // Send requestElementsInRect message.
    final ByteData? messageBytes =
        const JSONMessageCodec().encodeMessage(<String, dynamic>{
      'args': <dynamic>[0.0, 50.0, 50.0, 100.0],
      'method': 'Scribble.requestElementsInRect',
    });
    ByteData? responseBytes;
    await ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/scribble',
      messageBytes,
      (ByteData? response) {
        responseBytes = response;
      },
    );

    <FakeScribbleElement>[...targetElements, ...otherElements].forEach(unregisterElements);

    final List<List<dynamic>> responses = (const JSONMessageCodec().decodeMessage(responseBytes) as List<dynamic>).cast<List<dynamic>>();
    expect(responses.first.length, 2);
    expect(responses.first.first, containsAllInOrder(<dynamic>[targetElements.first.elementIdentifier, 0.0, 0.0, 100.0, 100.0]));
    expect(responses.first.last, containsAllInOrder(<dynamic>[targetElements.last.elementIdentifier, 0.0, 100.0, 100.0, 100.0]));
  });

  test('Scribble.setSelectionRects', () async {
    Scribble.ensureInitialized();
    final List<MethodCall> log = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.scribble, (MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });

    const List<SelectionRect> selectionRects = <SelectionRect>[
      SelectionRect(position: 1, bounds: Rect.fromLTWH(2, 3, 4, 5), direction: TextDirection.rtl),
    ];
    Scribble.setSelectionRects(selectionRects);
    expect(log, hasLength(1));
    final MethodCall methodCall = log.first;
    expect(methodCall.method, equals('Scribble.setSelectionRects'));

    final List<List<num>> arguments = (methodCall.arguments as List<dynamic>).map<List<num>>((dynamic el) {
      return (el as List<dynamic>).map<num>((dynamic subEl) {
        return subEl as num;
      }).toList();
    }).toList();
    expect(arguments.length, 1);
    expect(arguments[0].length, 6);
    expect(arguments[0][0], 2); // left
    expect(arguments[0][1], 3); // top
    expect(arguments[0][2], 4); // width
    expect(arguments[0][3], 5); // height
    expect(arguments[0][4], 1); // position
    expect(arguments[0][5], TextDirection.rtl.index); // direction

    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.scribble, null);
  });
}
