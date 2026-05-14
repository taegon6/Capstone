function tests = test_extractFeatures
tests = functiontests(localfunctions);
end

function testExtractsExpectedFeatureColumns(testCase)
data = generateMockCsiData(fs=20, durationSec=6, numSubcarriers=16);
prep = preprocessCsi(data.csi);
[features, names, times] = extractCsiFeatures(prep.amplitudeZ, data.fs, windowSec=1, stepSec=0.5);
verifyEqual(testCase, size(features, 2), numel(names));
verifyGreaterThan(testCase, size(features, 1), 1);
verifyEqual(testCase, numel(times), size(features, 1));
verifyTrue(testCase, all(isfinite(features), 'all'));
end
