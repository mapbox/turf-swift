UNAME = ${shell uname}

ifeq ($(UNAME), Darwin)
PLATFORM = x86_64-apple-macosx10.10
EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
TEST_RESOURCES_DIRECTORY = ./.build/${PLATFORM}/debug/TurfPackageTests.xctest/Contents/Resources

else ifeq ($(UNAME), Linux)
PLATFORM = x86_64-unknown-linux
EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
TEST_RESOURCES_DIRECTORY = ${EXECUTABLE_DIRECTORY}
endif

RUN_RESOURCES_DIRECTORY = ${EXECUTABLE_DIRECTORY}

copyTestResources:
	mkdir -p ${TEST_RESOURCES_DIRECTORY}
	cp Tests/Fixtures/* ${TEST_RESOURCES_DIRECTORY}

test: copyTestResources
	swift test
