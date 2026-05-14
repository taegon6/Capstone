function tests = test_parseCsiLine
tests = functiontests(localfunctions);
end

function testParsesEsp32StyleLine(testCase)
[raw, ok] = parseCsiLine('I (1) wifi: CSI_DATA,[1,2,-3,4]');
verifyTrue(testCase, ok);
verifyEqual(testCase, raw, [1 2 -3 4]);
end

function testRejectsMalformedLine(testCase)
[raw, ok] = parseCsiLine('not a csi row');
verifyFalse(testCase, ok);
verifyEmpty(testCase, raw);
end
