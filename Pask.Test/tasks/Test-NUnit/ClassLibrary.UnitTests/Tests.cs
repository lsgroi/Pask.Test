﻿using NUnit.Framework;

namespace ClassLibrary.UnitTests
{
    [TestFixture]
    public class Tests
    {
        [Test]
        [Category("category1")]
        [Category("category3")]
        public void Test_1()
        {
            Assert.True(true);
        }

        [Test]
        public void Test_2()
        {
            Assert.True(true);
        }
    }
}
