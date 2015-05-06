// IMPORTANT: This test file plays audio

describe('pythy.Sound', function () {
  var doAfterSomeTime, timeout;

  // Note: If tests fail, try after increasing the timeout
  TIMEOUT = 15;
  doAfterSomeTime = function (func) { window.setTimeout(func, TIMEOUT) };

  asyncIt = function (testDescription, func) {
    it(testDescription, function (done) {
      doAfterSomeTime(function () {
        func();
        done();
      });
    });
  };

  describe('constructor', function () {
    asyncIt('should take an onSuccess callback, an onError callback and a url', function () {
      var execFunc;

      execFunc = function () { new pythy.Sound(); };
      assert.throws(execFunc, Error, 'Must provide either a url or number of samples with the sample rate optionally');

      execFunc = function () { new pythy.Sound(function () {}); };
      assert.throws(execFunc, Error, 'Must provide either a url or number of samples with the sample rate optionally');

      execFunc = function () { new pythy.Sound(function () {}, function () {}); };
      assert.throws(execFunc, Error, 'Must provide either a url or number of samples with the sample rate optionally');

      execFunc = function () { new pythy.Sound(function () {}, function () {}, ''); };
      assert.throws(execFunc, Error, 'Must provide either a url or number of samples with the sample rate optionally');

      execFunc = function () { new pythy.Sound(function () {}, function () {}, './sounds/test_mono.wav'); };
      assert.doesNotThrow(execFunc, Error);
    });

    asyncIt('should take an onSuccess callback, an onError callback, the number of samples and the sampling rate optionally', function () {
      var execFunc;

      execFunc = function () { new pythy.Sound(function () {}, function () {}, 100); };
      assert.doesNotThrow(execFunc, Error);

      execFunc = function () { new pythy.Sound(function () {}, function () {}, 100, 3000); };
      assert.doesNotThrow(execFunc, Error);
    });

    asyncIt('should have the default sampling rate if not provided', function () {
      var onSuccess, sound;

      onSuccess = function (snd) { sound = snd; };

      new pythy.Sound(onSuccess, null, 300);

      assert.strictEqual(sound.getSamplingRate(), 22050);
    });

    describe('onSuccess callback', function () {
      var spy;

      beforeEach(function () {
        spy = sinon.spy();
      });

      it('should be called with the Sound object when the sound file is loaded from a remote url', function (done) {
        doAfterSomeTime(function () {
          new pythy.Sound(spy, function () {}, './sounds/test_mono.wav');

          doAfterSomeTime(function () {
            var args;

            assert.isTrue(spy.calledOnce);
            args = spy.getCall(0).args;
            assert.lengthOf(args, 1);
            assert.instanceOf(args[0], pythy.Sound);
            done();
          });
        });
      });

      asyncIt('should be called when an empty sound is created', function () {
        new pythy.Sound(spy, function () {}, 300);
        assert.isTrue(spy.calledOnce);
        args = spy.getCall(0).args;
        assert.lengthOf(args, 1);
        assert.instanceOf(args[0], pythy.Sound);
      });
    });

    describe('onError callback', function () {
      it('should be called when the remote sound file could not be loaded', function (done) {
        doAfterSomeTime(function () {
          var spy, args;

          spy = sinon.spy();

          new pythy.Sound(function () {}, spy, 'a');

          doAfterSomeTime(function () {
            assert.isTrue(spy.calledOnce);
            args = spy.getCall(0).args;
            assert.lengthOf(args, 1);
            assert.strictEqual(args[0], 'File not found');
            done();
          });
        });
      });

      it('should be called when the file is not of the correct type', function (done) {
        doAfterSomeTime(function () {
          var spy, args;

          spy = sinon.spy();

          new pythy.Sound(function () {}, spy, '/index.html');

          doAfterSomeTime(function () {
            assert.isTrue(spy.calledOnce);
            args = spy.getCall(0).args;
            assert.lengthOf(args, 1);
            assert.strictEqual(args[0], 'File not found or is not of the correct type');
            done();
          });
        });
      });
    });
  });

  describe('getUrl', function () {
    it('should return the correct url', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          assert.strictEqual(sound.getUrl(), './sounds/test_stereo.wav');
          done();
        });
      });
    });
  });

  describe('play', function () {
    var onSuccess, sound;

    onSuccess = function (snd) { sound = snd; };

    beforeEach(function () { sound = null; });

    it('should start playing the sound', function (done) {
      doAfterSomeTime(function () {
        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          var stub, args;
          stub = sinon.stub(window.AudioBufferSourceNode.prototype, 'start');

          sound.play();

          assert.isTrue(stub.calledOnce);
          args = stub.getCall(0).args
          assert.lengthOf(args, 1);
          assert.strictEqual(args[0], 0);
          stub.restore();
          done();
        });
      });
    });

    it('should call the callback at the end', function (done) {
      doAfterSomeTime(function () {
        new pythy.Sound(onSuccess, null, './sounds/test_mono.wav');

        doAfterSomeTime(function () {
          var callback;

          callback = sinon.spy();

          sound.play(callback);

          window.setTimeout(function () {
            assert.isTrue(callback.calledOnce);
            done();
          }, sound.getDuration() * 1000 + TIMEOUT);

        });
      });
    });
  });

  describe('playBefore', function () {
    it('should play the sound only till the given time', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          var stub, args;
          stub = sinon.stub(window.AudioBufferSourceNode.prototype, 'start');

          sound.playBefore(0.5);

          assert.isTrue(stub.calledOnce);
          args = stub.getCall(0).args
          assert.lengthOf(args, 3);
          assert.strictEqual(args[0], 0);
          assert.strictEqual(args[1], 0);
          assert.strictEqual(args[2], 0.5);
          stub.restore();
          done();
        });
      });
    });
  });

  describe('playAfter', function () {
    it('should play the sound after the given time', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          var stub, args;
          stub = sinon.stub(window.AudioBufferSourceNode.prototype, 'start');

          sound.playAfter(0.5);

          assert.isTrue(stub.calledOnce);
          args = stub.getCall(0).args
          assert.lengthOf(args, 2);
          assert.strictEqual(args[0], 0);
          assert.strictEqual(args[1], 0.5);
          stub.restore();
          done();
        });
      });
    });
  });

  describe('playSelection', function () {
    it('should play the sound between the given times', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          var stub, args;
          stub = sinon.stub(window.AudioBufferSourceNode.prototype, 'start');

          sound.playSelection(0.5, 0.75);

          assert.isTrue(stub.calledOnce);
          args = stub.getCall(0).args
          assert.lengthOf(args, 3);
          assert.strictEqual(args[0], 0);
          assert.strictEqual(args[1], 0.5);
          assert.strictEqual(args[2], 0.25);
          stub.restore();
          done();
        });
      });
    });
  });

  describe('stop', function () {
    it('should stop all the sounds being played', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          var spy, args;
          spy = sinon.spy(window.AudioBufferSourceNode.prototype, 'stop');

          sound.play();
          sound.playBefore(0.5);
          sound.playAfter(0.5);
          sound.playSelection(0.5, 0.75);
          sound.stop();

          assert.strictEqual(spy.callCount, 4);
          spy.restore();
          done();
        });
      });
    });
  });

  describe('getDuration', function () {
    it('should return the duration of the sound', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          assert.closeTo(sound.getDuration(), 2, 0.01);
          done();
        });
      });
    });
  });

  describe('getLength', function () {
    it('should return the number of samples of the sound', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          assert.strictEqual(sound.getLength(), 88471);
          done();
        });
      });
    });
  });

  describe('getLeftSample', function () {
    var onSuccess, sound;

    onSuccess = function (snd) { sound = snd; };

    beforeEach(function () {
      sound = null;
    });

    it('should return the value of the sample at the given index', function (done) {
      doAfterSomeTime(function () {
        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          assert.closeTo(sound.getLeftSample(30), 0.00045, 0.00001);
          done();
        });
      });
    });
  });

  describe('setLeftSample', function () {
    it('should set the value of the sample at the given index with the given value', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          sound.setLeftSample(30, 0);
          assert.strictEqual(sound.getLeftSample(30), 0);
          done();
        });
      });
    });
  });

  describe('getRightSample', function () {
    var onSuccess, sound;

    onSuccess = function (snd) { sound = snd; };

    beforeEach(function () {
      sound = null;
    });

    it('should return the value of the sample at the given index', function (done) {
      doAfterSomeTime(function () {
        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          assert.closeTo(sound.getRightSample(30), 0.00034, 0.00001);
          done();
        });
      });
    });
  });

  describe('setRightSample', function () {
    it('should set the value of the sample at the given index with the given value', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          sound.setRightSample(30, 0);
          assert.strictEqual(sound.getRightSample(30), 0);
          done();
        });
      });
    });
  });

  describe('getSample', function () {
    var onSuccess, sound;

    onSuccess = function (snd) { sound = snd; };

    beforeEach(function () {
      sound = null;
    });

    it('should return the value of the sample of the given channel at the given index', function (done) {
      doAfterSomeTime(function () {
        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          assert.closeTo(sound.getSample(1, 30), 0.00034, 0.00001);
          assert.closeTo(sound.getSample(0, 30), 0.00045, 0.00001);
          done();
        });
      });
    });
  });

  describe('getSamplingRate', function () {
    it('should the sampling rate of the sound', function (done) {
      doAfterSomeTime(function () {
        var onSuccess, sound;

        onSuccess = function (snd) { sound = snd; };

        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          assert.strictEqual(sound.getSamplingRate(), 44100);
          done();
        });
      });
    });
  });

  describe('save', function () {
    var onSuccess, sound;

    onSuccess = function (snd) { sound = snd; };

    beforeEach(function () { sound = null; });
    
    it('should save filenames ending with the mp3 extension as wavmp3 files on the server', function (done) {
      doAfterSomeTime(function () {
        var spy;
        spy = sinon.spy(window.pythy, 'uploadFileFromBlob'); 
        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          sound.save('file.mp3');
          assert.strictEqual(spy.getCall(0).args[0], 'file.wavmp3');
          spy.restore();
          done();
        });
      });
    });

    it('should create a wav binary', function (done) {
      doAfterSomeTime(function () {
        var spy;
        spy = sinon.spy(window.pythy, 'uploadFileFromBlob'); 
        new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

        doAfterSomeTime(function () {
          var args;

          sound.save('file.mp3');
          assert.isTrue(spy.calledOnce);
          args = spy.getCall(0).args;
          assert.lengthOf(args, 2);
          assert.instanceOf(args[1], Blob);
          assert.strictEqual(args[1].size, sound.getLength() * 4 + 44);
          spy.restore();
          done();
        });
      });
    });

    describe('blob mimetype', function () {
      it('should be correct for mp3 files', function (done) {
        doAfterSomeTime(function () {
          var spy;
          spy = sinon.spy(window.pythy, 'uploadFileFromBlob'); 
          new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

          doAfterSomeTime(function () {
            var args;

            sound.save('file.mp3');
            args = spy.getCall(0).args;
            assert.strictEqual(args[1].type, 'audio/mpeg');
            spy.restore();
            done();
          });
        });
      });

      it('should be correct for wav files', function (done) {
        doAfterSomeTime(function () {
          var spy;
          spy = sinon.spy(window.pythy, 'uploadFileFromBlob'); 
          new pythy.Sound(onSuccess, null, './sounds/test_stereo.wav');

          doAfterSomeTime(function () {
            var args;

            sound.save('file.wav');
            args = spy.getCall(0).args;
            assert.strictEqual(args[1].type, 'audio/wav');
            spy.restore();
            done();
          });
        });
      });
    });
  });
});
