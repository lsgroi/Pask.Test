using Xunit;

namespace ClassLibrary.IntegrationTests
{
    public class xUnitTests
    {
        [Fact]
        public void Test_3()
        {
            Assert.True(true);
        }

        [Fact]
        [Trait("TestCategory", "category1")]
        public void Test_4()
        {
            Assert.True(true);
        }
    }
}
