using NUnit.Framework;

namespace ClassLibrary.IntegrationTests
{
    [TestFixture]
    public class Tests
    {
        [Test]
        [Category("category2")]
        [Category("category3")]
        public void Test_3()
        {
            Assert.True(true);
        }
    }
}
