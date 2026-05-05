import unittest
import pathlib
from mopyregtest import RegressionTest

this_folder = pathlib.Path(__file__).absolute().parent
package_folder = this_folder / "../src/DateTime"
result_folder = this_folder / "results"

class TestDatetimeDateAndTime(unittest.TestCase):
    def test_TestDayOfWeek(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestDayOfWeek"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestAddSecondsToDatetime(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestAddSecondsToDatetime"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestYearToTransitionDatetime(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestYearToTransitionDatetime"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestIsValidDatetime(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestIsValidDatetime"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestIsWatchtimeInDaylightSaving(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestIsWatchtimeInDaylightSaving"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestIsStandardTimeInDaylightSaving(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestIsStandardTimeInDaylightSaving"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestDatetimeToPosix(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestDatetimeToPosix"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestPosixToDatetime(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestPosixToDatetime"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestRoundTripPosixToPosix(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestRoundTripPosixToPosix"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestRoundTripDatetimeToDatetime(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestRoundTripDatetimeToDatetime"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestCorrectInvalidDatetime(self):
        model_name = "DateTime.Examples.UnitTests.DateAndTime.TestCorrectInvalidDatetime"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

if __name__ == '__main__':
    unittest.main()
