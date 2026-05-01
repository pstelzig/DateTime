import unittest
import pathlib
from mopyregtest import RegressionTest

this_folder = pathlib.Path(__file__).absolute().parent
package_folder = this_folder / "../src/DateTime"
result_folder = this_folder / "results"

class TestDatetimeLeapSeconds(unittest.TestCase):
    def test_TestDatetimeToPosixWithLeapSeconds(self):
        model_name = "DateTime.Examples.UnitTests.LeapSeconds.TestDatetimeToPosixWithLeapSeconds"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_simulation()
        #tester.cleanup(ask_confirmation=False)

    def test_TestDatetimeToPosixOnLeapInsertion(self):
        model_name = "DateTime.Examples.UnitTests.LeapSeconds.TestDatetimeToPosixOnLeapInsertion"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_simulation()
        #tester.cleanup(ask_confirmation=False)

    def test_TestPosixToDatetimeWithLeapSeconds(self):
        model_name = "DateTime.Examples.UnitTests.LeapSeconds.TestPosixToDatetimeWithLeapSeconds"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_simulation()
        #tester.cleanup(ask_confirmation=False)

    def test_TestPosixToDatetimeOnLeapInsertion(self):
        model_name = "DateTime.Examples.UnitTests.LeapSeconds.TestPosixToDatetimeOnLeapInsertion"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_simulation()
        #tester.cleanup(ask_confirmation=False)

if __name__ == '__main__':
    unittest.main()
