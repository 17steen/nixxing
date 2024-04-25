#include <iostream>
#include <opencv2/core/utility.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>

int main() {
    std::cout << cv::getBuildInformation() << std::endl;
    return 0;
}
