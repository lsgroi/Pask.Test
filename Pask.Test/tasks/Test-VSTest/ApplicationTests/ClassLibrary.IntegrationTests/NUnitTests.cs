using NUnit.Framework;

namespace ClassLibrary.IntegrationTests
{
    [TestFixture]
    public class NUnitTests
    {
        [Test]
        public void Test_3()
        {
            Assert.True(true);
        }

        [Test]
        [Category("category1")]
        public void Test_4()
        {
            Assert.True(true);
        }
    }
}
