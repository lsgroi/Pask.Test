using Xunit;

namespace ClassLibrary.UnitTests
{
    public class xUnitTests
    {
        [Fact]
        [Trait("TestCategory", "category2")]
        public void Test_1()
        {
            Assert.True(true);
        }

        [Fact]
        [Trait("TestCategory", "category2")]
        public void Test_2()
        {
            Assert.True(true);
        }
    }
}
