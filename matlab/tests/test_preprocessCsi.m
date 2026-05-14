function tests = test_preprocessCsi
tests = functiontests(localfunctions);
end

function testPreprocessReturnsFiniteZscore(testCase)
data = generateMockCsiData(fs=20, durationSec=5, numSubcarriers=16);
prep = preprocessCsi(data.csi);
verifySize(testCase, prep.amplitudeZ, size(data.csi));
verifyTrue(testCase, all(isfinite(prep.amplitudeZ), 'all'));
end
