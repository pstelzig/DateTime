import unittest
import pathlib

this_folder = pathlib.Path(__file__).absolute().parent

from mopyregtest import RegressionTest

package_folder = this_folder / "../src/DateTime"
result_folder = this_folder / "results"
reference_folder = this_folder / "references"

class TestDatetimeBasic(unittest.TestCase):
    def test_TestSplitString(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestSplitString"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestSplit(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestSplit"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestIsDigit(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestIsDigit"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestFindFirstDigit(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestFindFirstDigit"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestParseTimefield(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestParseTimefield"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestParseTransition(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestParseTransition"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestParseTimezone(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestParseTimezone"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestParseDate(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestParseDate"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestParseDatetime(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestParseDatetime"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestDatetimeToString(self):
        model_name = "DateTime.Examples.UnitTests.Basic.TestDatetimeToString"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)



if __name__ == '__main__':
    unittest.main()        



